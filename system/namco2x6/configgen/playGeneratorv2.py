from __future__ import annotations

import sys
import os
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import TYPE_CHECKING, Final

import evdev

from configgen import Command
from configgen.batoceraPaths import CACHE, CONFIGS, SAVES, configure_emulator, mkdir_if_not_exists
from configgen.generators.Generator import Generator

# ------------------------------------------------------------
# Paths
# ------------------------------------------------------------

PLAY_CONFIG: Final = CONFIGS / "play"
PLAY_SAVES: Final = SAVES / "play"
PLAY_CONFIG_FILE: Final = PLAY_CONFIG / "Play Data Files" / "config.xml"
PLAY_INPUT_FILE: Final = PLAY_CONFIG / "Play Data Files" / "inputprofiles" / "default.xml"


# ------------------------------------------------------------
# Preferences
# ------------------------------------------------------------

PREFERENCES = {
    "ps2.arcaderoms.directory": {"Type": "path", "Value": "/userdata/roms/namco2x6"},
    "ui.showexitconfirmation": {"Type": "boolean", "Value": "false"},
    "ui.pausewhenfocuslost": {"Type": "boolean", "Value": "false"},
    "ui.showeecpuusage": {"Type": "boolean", "Value": "false"},
    "ps2.limitframerate": {"Type": "boolean", "Value": "true"},
    "renderer.widescreen": {"Type": "boolean", "Value": "false"},
    "system.language": {"Type": "integer", "Value": "2"},
    "video.gshandler": {"Type": "integer", "Value": "0"},
    "renderer.opengl.resfactor": {"Type": "integer", "Value": "1"},
    "renderer.presentationmode": {"Type": "integer", "Value": "1"},
    "renderer.opengl.forcebilineartextures": {"Type": "boolean", "Value": "false"},
}

OVERRIDES = {
    "ps2.limitframerate": "play_vsync",
    "renderer.widescreen": "play_widescreen",
    "system.language": "play_language",
    "video.gshandler": "play_api",
    "renderer.opengl.resfactor": "play_scale",
    "renderer.presentationmode": "play_mode",
    "renderer.opengl.forcebilineartextures": "play_filter",
}


# ------------------------------------------------------------
# Input mappings
# ------------------------------------------------------------

BASE_EVMAP = {
    "a": [16],
    "b": [17],
    "x": [18],
    "y": [19],
    "start": [2],
    "select": [6],
    "pageup": [20],
    "pagedown": [22],
    "joystick1left": [105, 106],
    "joystick1up": [103, 108],
    "joystick1up_pedal": [23, 21],
    "up": [103],
    "down": [108],
    "left": [105],
    "right": [106],
    "l2": [21],
    "r2": [23],
    "l3": [24],
    "r3": [25],
}

PLAYER_OFFSET = {1: 0, 2: 14}


def build_evmap(player: int) -> dict[str, list[int]]:
    offset = PLAYER_OFFSET[player]
    return {k: [v + offset for v in values] for k, values in BASE_EVMAP.items()}


PLAY_MAPPING_BASE = {
    "square": "y",
    "triangle": "x",
    "circle": "b",
    "cross": "a",
    "start": "start",
    "select": "select",
    "l2": "pageup",
    "r2": "pagedown",
    "analog_left_x": "joystick1left",
    "analog_left_y": "joystick1up",
    "dpad_up": "up",
    "dpad_down": "down",
    "dpad_left": "left",
    "dpad_right": "right",
    "l1": "l2",
    "r1": "r2",
    "l3": "l3",
    "r3": "r3",
}


GAME_MAPPING_RULES = [
    ("prdgp03", lambda m: (m.update({"r1": "y"}), m.pop("square", None))),
    ("fghtjam", lambda m: m.update({"triangle": "l2", "square": "x", "r3": "y"})),
    ("superdbz", lambda m: m.update({"square": "x", "r3": "y"})),
    ("tekken", lambda m: m.update({"square": "x", "r3": "y"})),
    ("acedriv3", lambda m: (
        m.update({"analog_left_y": "joystick1up_pedal"}),
        m.pop("l1", None),
        m.pop("r1", None),
    )),
    ("wangan", lambda m: (
        m.update({"analog_left_y": "joystick1up_pedal"}),
        m.pop("l1", None),
        m.pop("r1", None),
    )),
]


# ------------------------------------------------------------
# Input helpers (CRITICAL for Play standalone)
# ------------------------------------------------------------

PAD_GUID = "1:0:1:0:1:0"
PROVIDER_ID = 1702257782
KEY_TYPE = 0


def add_binding(input_root, nplayer, play_key, idx, key_code):
    base = f"input.pad{nplayer}.{play_key}.bindingtarget{idx}"

    ET.SubElement(input_root, "Preference",
        Name=f"{base}.deviceId", Type="string", Value=PAD_GUID)

    ET.SubElement(input_root, "Preference",
        Name=f"{base}.keyId", Type="integer", Value=str(key_code))

    ET.SubElement(input_root, "Preference",
        Name=f"{base}.keyType", Type="integer", Value=str(KEY_TYPE))

    ET.SubElement(input_root, "Preference",
        Name=f"{base}.providerId", Type="integer", Value=str(PROVIDER_ID))


# ------------------------------------------------------------
# Generator
# ------------------------------------------------------------

class PlayGenerator(Generator):

    def getHotkeysContext(self) -> HotkeysContext:
        return {"name": "play", "keys": {"exit": ["KEY_LEFTALT", "KEY_F4"]}}

    def generate(self, system, rom, playersControllers, metadata, guns, wheels, gameResolution):

        mkdir_if_not_exists(PLAY_CONFIG)
        mkdir_if_not_exists(PLAY_SAVES)

        # -------- config.xml --------
        if PLAY_CONFIG_FILE.exists():
            tree = ET.parse(PLAY_CONFIG_FILE)
            root = tree.getroot()
        else:
            root = ET.Element("Config")

        for name, attrs in PREFERENCES.items():
            pref = root.find(f".//Preference[@Name='{name}']")
            if pref is None:
                pref = ET.SubElement(root, "Preference", Name=name)

            pref.attrib.update(attrs)

            if override := OVERRIDES.get(name):
                if value := system.config.get(override):
                    pref.attrib["Value"] = value

        PLAY_CONFIG_FILE.parent.mkdir(parents=True, exist_ok=True)
        ET.ElementTree(root).write(PLAY_CONFIG_FILE)

        # -------- input profiles --------
        input_root = ET.Element("Config")
        rom_str = str(rom)

        for nplayer, controller in enumerate(playersControllers[:2], start=1):
            evmap = build_evmap(nplayer)
            play_mapping = PLAY_MAPPING_BASE.copy()

            for needle, rule in GAME_MAPPING_RULES:
                if needle in rom_str:
                    rule(play_mapping)
                    break

            ET.SubElement(
                input_root,
                "Preference",
                Name=f"input.pad{nplayer}.analog.sensitivity",
                Type="float",
                Value="1.0",
            )

            for play_key, joystick_key in play_mapping.items():
                if joystick_key not in evmap:
                    continue

                key_codes = evmap[joystick_key]
                binding_type = 2 if len(key_codes) > 1 else 1

                hat_value = -1
                if play_key in ("dpad_up", "dpad_left"):
                    hat_value = 4
                elif play_key in ("dpad_down", "dpad_right"):
                    hat_value = 0

                ET.SubElement(
                    input_root,
                    "Preference",
                    Name=f"input.pad{nplayer}.{play_key}.bindingtype",
                    Type="integer",
                    Value=str(binding_type),
                )

                ET.SubElement(
                    input_root,
                    "Preference",
                    Name=f"input.pad{nplayer}.{play_key}.povhatbinding.refvalue",
                    Type="integer",
                    Value=str(hat_value),
                )

                for idx, key_code in enumerate(key_codes, start=1):
                    add_binding(input_root, nplayer, play_key, idx, key_code)

        PLAY_INPUT_FILE.parent.mkdir(parents=True, exist_ok=True)
        tree = ET.ElementTree(input_root)
        ET.indent(tree, space="    ", level=0)
        tree.write(PLAY_INPUT_FILE)

        # -------- command --------
        cmd = [
            Path("/userdata/system/dcg/namco2x6/appimage/play.AppImage"),
            "--fullscreen",
        ]

        if not configure_emulator(rom):
            if rom.suffix.lower() == ".zip":
                cmd += ["--arcade", rom.stem]
            else:
                cmd += ["--disc", rom]

        print(cmd, file=sys.stderr)
         
        return Command.Command(
            array=cmd,
            env={
                "XDG_CONFIG_HOME": PLAY_CONFIG,
                "XDG_DATA_HOME": PLAY_CONFIG,
                "XDG_CACHE_HOME": CACHE,
                "QT_QPA_PLATFORM": "xcb",
            },
        )


    def getInGameRatio(self, config, gameResolution, rom):
        if config.get("play_widescreen") == "true" or config.get("play_mode") == "0":
            return 16 / 9
        return 4 / 3
# ------------------------------------------------------------
# End of File