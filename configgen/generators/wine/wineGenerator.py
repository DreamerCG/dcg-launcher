from __future__ import annotations

import os
import sys
import subprocess
from pathlib import Path
from typing import TYPE_CHECKING

from configgen import Command
from configgen.controller import generate_sdl_game_controller_config
from configgen.exceptions import BatoceraException
from configgen.generators.Generator import Generator


if TYPE_CHECKING:
    from ...types import HotkeysContext


class WineGenerator(Generator):

    def getHotkeysContext(self) -> HotkeysContext:
        return {
            "name": "wine",
            "keys": { "exit": "/userdata/system/dcg/bin/batocera-wine windows stop" }
        }

    def generate(self, system, rom, playersControllers, metadata, guns, wheels, gameResolution):
        if system.name == "windows_installers":
            commandArray = ["/userdata/system/dcg/bin/batocera-wine", "windows", "install", rom]
            return Command.Command(array=commandArray)

        else:
            print("Commande : /userdata/system/dcg/bin/batocera-wine", system.name, file= sys.stderr)
            commandArray = ["/userdata/system/dcg/bin/batocera-wine", system.name, "play", rom]

            environment: dict[str, str | Path] = {}
            #system.language
            try:
                language = subprocess.check_output("batocera-settings-get system.language", shell=True, text=True).strip()
            except subprocess.CalledProcessError:
                language = 'en_US'
            if language:
                environment.update({
                    "LANG": language + ".UTF-8",
                    "LC_ALL": language + ".UTF-8"
                    }
                )
            # sdl controller option - default is on
            if system.config.get_bool("sdl_config", True):
                environment.update(
                    {
                        "SDL_GAMECONTROLLERCONFIG": generate_sdl_game_controller_config(playersControllers),
                        "SDL_JOYSTICK_HIDAPI": "0"
                    }
                )
            # ensure nvidia driver used for vulkan
            if Path('/var/tmp/nvidia.prime').exists():
                variables_to_remove = ['__NV_PRIME_RENDER_OFFLOAD', '__VK_LAYER_NV_optimus', '__GLX_VENDOR_LIBRARY_NAME']
                for variable_name in variables_to_remove:
                    if variable_name in os.environ:
                        del os.environ[variable_name]

                environment.update(
                    {
                        'VK_ICD_FILENAMES': '/usr/share/vulkan/icd.d/nvidia_icd.x86_64.json:/usr/share/vulkan/icd.d/nvidia_icd.i686.json',
                    }
                )

            return Command.Command(array=commandArray, env=environment)

    def getMouseMode(self, config, rom):
        return config.get_bool('force_mouse')
