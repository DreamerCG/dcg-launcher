#!/usr/bin/env python

from __future__ import annotations

import filecmp
import logging
import os
import re
import shutil
import subprocess
import sys
import json

from pathlib import Path, PureWindowsPath
from typing import TYPE_CHECKING

from configgen import Command as Command
from configgen.batoceraPaths import mkdir_if_not_exists
from configgen.controller import generate_sdl_game_controller_config
from configgen.generators.Generator import Generator
from configgen.utils.configparser import CaseSensitiveConfigParser

if TYPE_CHECKING:
    from configgen.types import HotkeysContext

eslog = logging.getLogger(__name__)

class DemulGenerator(Generator):

    def getHotkeysContext(self) -> HotkeysContext:
        return {
            "name": "demul",
            "keys": {}
        }

    @staticmethod
    def sync_directories(source_dir, dest_dir):
        dcmp = filecmp.dircmp(source_dir, dest_dir)
        # Files that are only in the source directory or are different
        differing_files = dcmp.diff_files + dcmp.left_only
        for file in differing_files:
            src_path = os.path.join(source_dir, file)
            dest_path = os.path.join(dest_dir, file)
            # Copy and overwrite the files from source to destination
            shutil.copy2(src_path, dest_path)

    def generate(self, system, rom, playersControllers, metadata, guns, wheels, gameResolution):
        wineprefix = '/userdata/system/wine-bottles/demul'

        winepath = '/userdata/system/wine/custom/ge-custom/'
        wineBinary = winepath + '/bin/wine64'


        emuConfig = '/userdata/system/dcg/configs/emulators/demul'
        emuCache = '/userdata/system/cache/demul'
        emupath = '/userdata/system/dcg/emulators/demul'

        # make system directories
        if not os.path.exists(wineprefix):
            os.makedirs(wineprefix)
        if not os.path.exists(emuCache):
            os.makedirs(emuCache)


        if os.path.isdir(winepath + 'lib/wine/x86_64-unix/'):
            wine_lib64_dir = winepath + 'lib/wine'
        else:
            wine_lib64_dir = winepath + 'lib/wine'

        wine_lib32_dir = winepath + 'lib/wine'

        if not os.path.exists(wineprefix + "/init.done"):
            cmd = [ wineBinary, 'hostname']

            env = {"LD_LIBRARY_PATH": "/lib32:${wine_lib64_dir}", "WINEPREFIX": wineprefix, "WINEDEBUG": "-all", "DXVK_LOG_LEVEL": "none", "VKD3D_DEBUG": "none", "VKD3D_SHADER_DEBUG": "none", "WINEDLLOVERRIDES": "winegstreamer.exe=" }
            env.update(os.environ)
            env["PATH"] = "${winepath}/bin:/bin:/usr/bin"
            eslog.debug(f"command: {str(cmd)}")
            proc = subprocess.Popen(cmd, env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            out, err = proc.communicate()
            exitcode = proc.returncode
            eslog.debug(out.decode())
            eslog.error(err.decode())
            with open(wineprefix + "/init.done", "w") as f:
                f.write("init")

        # check & copy newer dxvk files
        self.sync_directories("/usr/wine/dxvk/x64", wineprefix + "/drive_c/windows/system32")
        self.sync_directories("/usr/wine/dxvk/x32", wineprefix + "/drive_c/windows/syswow64")

        # determine what system to define for demul
        # -run=<name>           run specified system (dc, naomi, awave, hikaru, gaelco, cave3rd)
        if "naomi" in str(rom):
            demulsystem = "naomi"
        elif "hikaru" in str(rom):
            demulsystem = "hikaru"
        elif "gaelco" in str(rom):
            demulsystem = "gaelco"
        elif "cave3rd" in str(rom):
            demulsystem = "cave3rd"
        elif "dreamcast" in str(rom):
            demulsystem = "dc"
        elif "atomiswave" in str(rom):
            demulsystem = "awave"

        # remove the rom path & extension to simplify the rom name when needed
        # -rom=<romname>        run specified system rom from the rom path defined in Demul.ini
        # or -image=<full image path> for dreamcast
        romname = rom.name

        # move to the emulator path to ensure configs are saved etc
        os.chdir(emupath)
        configFileName = emupath + "/Demul.ini"
        Config = CaseSensitiveConfigParser(interpolation=None)
        Config.optionxform = str

        if os.path.exists(configFileName):
            try:
                with open(configFileName, 'r', encoding='utf_8_sig') as fp:
                    Config.read_file(fp)
            except:
                pass

        # add rom & bios paths to Demul.ini
        nvram = Path("/userdata/saves/demul/demul/nvram/")
        nvram_path_on_windows = PureWindowsPath(nvram)
        roms0 = Path("/userdata/roms/naomi2/")
        roms0_path_on_windows = PureWindowsPath(roms0)
        roms1 = Path("/userdata/bios/")
        roms1_path_on_windows = PureWindowsPath(roms1)
        roms2 = Path("/userdata/roms/hikaru")
        roms2_path_on_windows = PureWindowsPath(roms2)
        roms3 = Path("/userdata/roms/gaelco")
        roms3_path_on_windows = PureWindowsPath(roms3)
        roms4 = Path("/userdata/roms/cave3rd")
        roms4_path_on_windows = PureWindowsPath(roms4)
        roms5 = Path("/userdata/roms/dreamcast")
        roms5_path_on_windows = PureWindowsPath(roms5)
        roms6 = Path("/userdata/roms/atomiswave")
        roms6_path_on_windows = PureWindowsPath(roms6)
        roms7 = Path("/userdata/roms/naomi")
        roms7_path_on_windows = PureWindowsPath(roms7)
        plugins = Path(emupath + "/plugins/")
        plugins_path_on_windows = PureWindowsPath(plugins)

        if not Config.has_section("files"):
            Config.add_section("files")
        Config.set("files", "nvram", f"Z:{nvram_path_on_windows}")
        Config.set("files", "roms0", f"Z:{roms0_path_on_windows}")
        Config.set("files", "romsPathsCount", "8")
        Config.set("files", "roms1", f"Z:{roms1_path_on_windows}")
        Config.set("files", "roms2", f"Z:{roms2_path_on_windows}")
        Config.set("files", "roms3", f"Z:{roms3_path_on_windows}")
        Config.set("files", "roms4", f"Z:{roms4_path_on_windows}")
        Config.set("files", "roms5", f"Z:{roms5_path_on_windows}")
        Config.set("files", "roms6", f"Z:{roms6_path_on_windows}")
        Config.set("files", "roms7", f"Z:{roms7_path_on_windows}")

        if not Config.has_section("plugins"):
            Config.add_section("plugins")
        Config.set("plugins", "directory", f"Z:{plugins_path_on_windows}")
        Config.set("plugins", "spu", "spuDemul.dll")
        Config.set("plugins", "pad", "padDemul.dll")
        Config.set("plugins", "net", "netDemul.dll")
        # gaelco won't work with the new DX11 plugin
        if demulsystem == "gaelco":
            Config.set("plugins", "gpu", "gpuDX11old.dll")
        else:
            Config.set("plugins", "gpu", "gpuDX11.dll")

        # dreamcast needs the full path & cdi or gdi image extensions
        # check if we need to change the gdr plugin.
        if demulsystem == "dc":
            if ".chd" in rom:
                Config.set("plugins", "gdr", "gdrCHD.dll")
            else:
                Config.set("plugins", "gdr", "gdrImage.dll")
        # demul supports zip & 7zip romset extensions
        elif ".zip" in romname:
            smplromname = romname.replace(".zip", "")
            Config.set("plugins", "gdr", "gdrImage.dll")
        elif ".7z" in romname:
            smplromname = romname.replace(".7z", "")
            Config.set("plugins", "gdr", "gdrImage.dll")

        with open(configFileName, 'w', encoding='utf_8_sig') as configfile:
            Config.write(configfile)

        # add the windows rom path if dreamcast
        if demulsystem == "dc":
            dcrom_windows = PureWindowsPath(rom)
            # add Z:
            dcpath = f"Z:{dcrom_windows}"

        # adjust fullscreen & resolution to gpuDX11.ini
        if demulsystem == "gaelco":
            configFileName = emupath + "/gpuDX11old.ini"
        else:
           configFileName = emupath + "/gpuDX11.ini"

        Config = CaseSensitiveConfigParser(interpolation=None)
        Config.optionxform = str
        if os.path.exists(configFileName):
            try:
                with open(configFileName, 'r', encoding='utf_8_sig') as fp:
                    Config.read_file(fp)
            except:
                pass

        # set to be always fullscreen
        if not Config.has_section("main"):
            Config.add_section("main")
        Config.set("main","UseFullscreen", "0")
        # set resolution
        if not Config.has_section("resolution"):
            Config.add_section("resolution")
        # force 640x480 on gaelco
        if demulsystem == "gaelco":
            Config.set("resolution", "Width", "640")
            Config.set("resolution", "Height", "480")
        else:
            Config.set("resolution", "Width", str(gameResolution["width"]))
            Config.set("resolution", "Height", str(gameResolution["height"]))

        # now set the batocera options
        if system.isOptSet("demulRatio"):
            Config.set("main", "aspect", format(system.config["demulRatio"]))
        else:
            Config.set("main", "aspect", "1")

        if system.isOptSet("demulVSync"):
            Config.set("main", "Vsync", format(system.config["demulVSync"]))
        else:
            Config.set("main", "Vsync", "0")

        with open(configFileName, 'w', encoding='utf_8_sig') as configfile:
            Config.write(configfile)

        # copy system reshade config

        shutil.copy2(emupath + "/ReShade.ini." + demulsystem, emupath + "/ReShade.ini")

        # now setup the command array for the emulator

        commandArray = [wineBinary, "explorer", f"/desktop=Wine,{gameResolution['width']}x{gameResolution['height']}", emupath + '/AutoHotkey32.exe', 'newfullscreen.ahk', demulsystem, smplromname]

        environment={
                'WINEPREFIX': wineprefix,
                'LD_LIBRARY_PATH': '/usr/lib:/lib32:'+wine_lib32_dir+'/i386-unix:/lib:/usr/lib:'+wine_lib64_dir+'/x86_64-unix',
                'GST_PLUGIN_SYSTEM_PATH_1_0': '/usr/lib/gstreamer-1.0:/lib32/gstreamer-1.0',
                'GST_REGISTRY_1_0': '/userdata/system/.cache/gstreamer-1.0/registry.x86_64.bin:/userdata/system/.cache/gstreamer-1.0/registry..bin',
                'LIBGL_DRIVERS_PATH': '/lib32/dri:/usr/lib/dri',
                'WINEDLLPATH': wine_lib32_dir+'/i386-windows:'+wine_lib64_dir+'/x86_64-windows',
                'WINEDLLOVERRIDES': "winegstreamer.exe=;winemenubuilder.exe=;dxgi,d3d8,d3d9,d3d10core,d3d11,d3d12,d3d12core=n;nvapi64,nvapi=;",
		'DXVK_ASYNC':'1',
		'DXVK_CONFIG_FILE': "/userdata/system/wine/dxvk.conf",
		'DXVK_STATE_CACHE_PATH' : '/userdata/system/cache',
		'WINEDEBUG': '-all',
		'DXVK_LOG_LEVEL': 'none',
		'VKD3D_DEBUG': 'none',
		'VKD3D_SHADER_DEBUG': 'none',
                'LIBGL_DRIVERS_PATH': '/usr/lib/dri',
                'WINEESYNC': '0',
                'SDL_GAMECONTROLLERCONFIG': generate_sdl_game_controller_config(playersControllers),
                'SDL_JOYSTICK_HIDAPI': '0',


                # hum pw 0.2 and 0.3 are hardcoded, not nice
                'SPA_PLUGIN_DIR': '/usr/lib/spa-0.2:/lib32/spa-0.2',
                'PIPEWIRE_MODULE_DIR': '/usr/lib/pipewire-0.3:/lib32/pipewire-0.3',
                'VKD3D_SHADER_CACHE_PATH': emuCache
        }
        
        # ensure nvidia driver used for vulkan
        if os.path.exists('/var/tmp/nvidia.prime'):
            variables_to_remove = ['__NV_PRIME_RENDER_OFFLOAD', '__VK_LAYER_NV_optimus', '__GLX_VENDOR_LIBRARY_NAME']
            for variable_name in variables_to_remove:
                if variable_name in os.environ:
                    del os.environ[variable_name]
            
            environment.update(
                {
                    'VK_ICD_FILENAMES': '/usr/share/vulkan/icd.d/nvidia_icd.x86_64.json',
                    'VK_LAYER_PATH': '/usr/share/vulkan/explicit_layer.d'
                }
            )
        
        return Command.Command(array=commandArray, env=environment)
    
    def getMouseMode(self, config, rom):
        return True
