from __future__ import annotations

import re
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import TYPE_CHECKING, Final, cast

import evdev


from configgen import Command
from configgen.batoceraPaths import CACHE, CONFIGS, SAVES, configure_emulator, mkdir_if_not_exists
from configgen.generators.Generator import Generator

playConfig: Final = CONFIGS / 'play'
playSaves: Final = SAVES / 'play'
playConfigFile: Final = playConfig / 'Play Data Files' / 'config.xml'
playInputFile: Final = playConfig / 'Play Data Files' / 'inputprofiles' / 'default.xml'

class PlayGenerator(Generator):

    def getHotkeysContext(self) -> HotkeysContext:
        return {
            "name": "play",
            "keys": { "exit": ["KEY_LEFTALT", "KEY_F4"] }
        }

    def generate(self, system, rom, playersControllers, metadata, guns, wheels, gameResolution):
        # Create necessary directories
        mkdir_if_not_exists(playConfig)
        mkdir_if_not_exists(playSaves)

        ## Work with the config.xml file
        root = ET.Element('Config')

        # Dictionary of preferences and defaults
        preferences = {
            'ps2.arcaderoms.directory': {'Type': 'path', 'Value': '/userdata/roms/namco2x6'},
            'ui.showexitconfirmation': {'Type': 'boolean', 'Value': 'false'},
            'ui.pausewhenfocuslost': {'Type': 'boolean', 'Value': 'false'},
            'ui.showeecpuusage': {'Type': 'boolean', 'Value': 'false'},
            'ps2.limitframerate': {'Type': 'boolean', 'Value': 'true'},
            'renderer.widescreen': {'Type': 'boolean', 'Value': 'false'},
            'system.language': {'Type': 'integer', 'Value': '1'},
            'video.gshandler': {'Type': 'integer', 'Value': '0'},
            'renderer.opengl.resfactor': {'Type': 'integer', 'Value': '1'},
            'renderer.presentationmode': {'Type': 'integer', 'Value': '1'},
            'renderer.opengl.forcebilineartextures': {'Type': 'boolean', 'Value': 'false'},
        }

        # Check if the configuration file exists
        if playConfigFile.exists():
            tree = ET.parse(playConfigFile)
            root = tree.getroot()

        # Add or update preferences
        for pref_name, pref_attrs in preferences.items():
            pref_element = root.find(f".//Preference[@Name='{pref_name}']")
            if pref_element is None:
                # Create a new preference element if it doesn't exist
                pref_element = ET.SubElement(root, 'Preference', Name=pref_name)

            # Update attribute values
            for attr_name, attr_value in pref_attrs.items():
                pref_element.attrib[attr_name] = attr_value
                # Check system options for overriding values
                if pref_name == 'ps2.limitframerate' and (vsync := system.config.get('play_vsync')):
                    pref_element.attrib['Value'] = vsync
                if pref_name == 'renderer.widescreen' and (widescreen := system.config.get('play_widescreen')):
                    pref_element.attrib['Value'] = widescreen
                if pref_name == 'system.language' and (language := system.config.get('play_language')):
                    pref_element.attrib['Value'] = language
                if pref_name == 'video.gshandler' and (api := system.config.get('play_api')):
                    pref_element.attrib['Value'] = api
                if pref_name == 'renderer.opengl.resfactor' and (scale := system.config.get('play_scale')):
                    pref_element.attrib['Value'] = scale
                if pref_name == 'renderer.presentationmode' and (mode := system.config.get('play_mode')):
                    pref_element.attrib['Value'] = mode
                if pref_name == 'renderer.opengl.forcebilineartextures' and (filter := system.config.get('play_filter')):
                    pref_element.attrib['Value'] = filter

        # Write the updated configuration back to the file
        tree = ET.ElementTree(root)
        playConfigFile.parent.mkdir(parents=True, exist_ok=True)
        tree.write(playConfigFile)

        evmapy = {
            1: {
                'a': [16],
                'b': [17],
                'x': [18],
                'y': [19],
                'start': [2],
                'select': [6],
                'pageup': [20],
                'pagedown': [22],
                'joystick1left': [105, 106],
                'joystick1up': [103, 108],
                'joystick1up_pedal': [23, 21],
                'up': [103],
                'down': [108],
                'left': [105],
                'right': [106],
                'l2': [21],
                'r2': [23],
                'l3': [24],
                'r3': [25],
            },
            2: {
                'a': [30],
                'b': [31],
                'x': [32],
                'y': [33],
                'start': [3],
                'select': [7],
                'pageup': [34],
                'pagedown': [36],
                'joystick1left': [46, 47],
                'joystick1up': [44, 45],
                'up': [44],
                'down': [45],
                'left': [46],
                'right': [47],
                'l2': [35],
                'r2': [37],
                'l3': [38],
                'r3': [39]
            }
        }

        ## Default games mapping
        #cross: button 1
        #circle: button 2
        #triangle : button3
        #square : button4
        #r3: button 5
        #r2: button 6
        playMapping = {
            'square': 'y',
            'triangle': 'x',
            'circle': 'b',
            'cross': 'a',
            'start': 'start',
            'select': 'select',
            'l2':'pageup',
            'r2':'pagedown',
            'analog_left_x': 'joystick1left',
            'analog_left_y': 'joystick1up',
            'analog_right_x': 'joystick2left',
            'analog_right_y': 'joystick2up',
            'dpad_up': 'up',
            'dpad_down': 'down',
            'dpad_left': 'left',
            'dpad_right': 'right',
            'l1': 'l2',
            'r1': 'r2',
            'l3': 'l3',
            'r3': 'r3'
        }

        if 'prdgp03' in str(rom):
            playMapping['r1'] = 'y'
            del playMapping['square']
        elif 'fghtjam' in str(rom):
            playMapping['triangle'] = 'l2'
            playMapping['square'] = 'x'
            playMapping['r3'] = 'y'
            playMapping['r2'] = 'r2'
        elif 'superdbz' in str(rom):
            playMapping['square'] = 'x'
            playMapping['r3'] = 'y'
        elif 'tekken' in str(rom):
            playMapping['square'] = 'x'
            playMapping['r3'] = 'y'
        elif 'acedriv3' in str(rom) or 'wangan' in str(rom):
            playMapping['analog_left_y'] = 'joystick1up_pedal'
            del playMapping['l1']
            del playMapping['r1']

        def create_input_binding_preferences(input_config, pad_guid, key_id, key_type, provider_id, nplayer, play_key, binding_target):
            """Helper function to create XML preferences for joystick inputs."""
            ET.SubElement(input_config,
                          "Preference",
                          Name=f"input.pad{nplayer}.{play_key}.{binding_target}.deviceId",
                          Type="string",
                          Value=pad_guid)

            ET.SubElement(input_config,
                          "Preference",
                          Name=f"input.pad{nplayer}.{play_key}.{binding_target}.keyId",
                          Type="integer",
                          Value=str(key_id))

            ET.SubElement(input_config,
                          "Preference",
                          Name=f"input.pad{nplayer}.{play_key}.{binding_target}.keyType",
                          Type="integer",
                          Value=str(key_type))

            ET.SubElement(input_config,
                          "Preference",
                          Name=f"input.pad{nplayer}.{play_key}.{binding_target}.providerId",
                          Type="integer",
                          Value=str(provider_id))

        def create_input_preferences(input_config, pad_guid, nplayer, joystick_name, binding_type, hat_value):
            """Helper function to create XML preferences for joystick inputs."""
            ET.SubElement(input_config,
                          "Preference",
                          Name=f"input.pad{nplayer}.{play_key}.bindingtype",
                          Type="integer",
                          Value=str(binding_type))

            ET.SubElement(input_config,
                          "Preference",
                          Name=f"input.pad{nplayer}.{play_key}.povhatbinding.refvalue",
                          Type="integer",
                          Value=str(hat_value))

        input_config = ET.Element("Config")

        # Iterate over connected controllers with a limit of 2 players
        for nplayer, controller in enumerate(playersControllers[:2], start=1):
            dev = evdev.InputDevice(controller.device_path)
            pad_guid = "1:0:1:0:1:0"
            provider_id = 1702257782

            # Write this per pad
            ET.SubElement(
                input_config,
                "Preference",
                Name=f"input.pad{nplayer}.analog.sensitivity",
                Type="float",
                Value=str(1.000000)
            )

            for play_key in playMapping:
                joystick_key = playMapping[play_key]

                if joystick_key not in evmapy[nplayer]:
                    continue

                evmapy_mapping = evmapy[nplayer][joystick_key]

                binding_type = 1
                #simulated axis
                if len(evmapy_mapping) > 1:
                    binding_type = 2

                hat_value = -1
                if play_key in ['dpad_up', 'dpad_left']:
                    hat_value = 4
                elif play_key in ['dpad_down', 'dpad_right']:
                    hat_value = 0

                create_input_preferences(input_config, pad_guid, nplayer, play_key, binding_type, hat_value)

                bindingtarget_index = 1
                for key_code in evmapy_mapping:
                    key_type = 0
                    bindingtarget = f"bindingtarget{bindingtarget_index}"
                    create_input_binding_preferences(input_config, pad_guid, key_code, key_type, provider_id, nplayer, play_key, bindingtarget)
                    bindingtarget_index = bindingtarget_index + 1

        # Save the controller settings to the specified input file
        input_tree = ET.ElementTree(input_config)
        ET.indent(input_tree, space="    ", level=0)
        playInputFile.parent.mkdir(parents=True, exist_ok=True)
        input_tree.write(playInputFile)

        ## Prepare the command to run the emulator
        commandArray: list[str | Path] = ["/userdata/system/dcg/namco2x6/appimage/play.AppImage", "--fullscreen"]

        if not configure_emulator(rom):
            # if zip, it's a namco arcade game
            if rom.suffix.lower() == ".zip":
                # strip path & extension
                commandArray.extend(["--arcade", Path(rom).stem])
            else:
                commandArray.extend(["--disc", rom])

        return Command.Command(
            array=commandArray,
            env={
                "XDG_CONFIG_HOME": playConfig,
                "XDG_DATA_HOME": playConfig,
                "XDG_CACHE_HOME": CACHE,
                "QT_QPA_PLATFORM": "xcb"
            }
        )

    def getInGameRatio(self, config, gameResolution, rom):
        if config.get('play_widescreen') == "true" or config.get('play_mode') == "0":
            return 16/9
        return 4/3
