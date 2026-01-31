#!/usr/bin/python
# -*- coding: utf-8 -*-
import re
import sys
import os
import yaml

from importlib import import_module
import configgen
from configgen.Emulator import Emulator, _dict_merge, _load_defaults, _load_system_config
from configgen.emulatorlauncher import launch
from configgen.generators import get_generator
from typing import TYPE_CHECKING, Any
from pathlib import Path

rom = None
if "-rom" in sys.argv:
    rom = sys.argv[sys.argv.index("-rom") + 1]
if "-emulator" in sys.argv:
    emulator_name = sys.argv[sys.argv.index("-emulator") + 1]

def ensure_namco2x6_keys():
    src = Path("/userdata/system/dcg/namco2x6/evmapy/namco2x6.keys")
    dst_dir = Path("/userdata/system/configs/evmapy")
    dst = dst_dir / "namco2x6.keys"

    if dst.exists():
        return

    if not src.exists():
        print(f"[WARN] Source keys file missing: {src}", file=sys.stderr)
        return

    try:
        dst_dir.mkdir(parents=True, exist_ok=True)
        dst.write_bytes(src.read_bytes())
        print(f"[INFO] Copied namco2x6.keys to {dst}", file=sys.stderr)
    except Exception as e:
        print(f"[ERROR] Failed to copy namco2x6.keys: {e}", file=sys.stderr)


def _new_get_generator(emulator: str):
    
    print(f"Selected emulator: {emulator}", file=sys.stderr)    
    print(f"Selected Rom : {rom}", file=sys.stderr)    

    if emulator == 'play':
        from playGenerator import PlayGenerator
        return PlayGenerator()

    #fallback to batocera generators
    return get_generator(emulator)
    
from configgen.batoceraPaths import DEFAULTS_DIR
configgen.emulatorlauncher.get_generator = _new_get_generator

if __name__ == "__main__":
    ensure_namco2x6_keys()
    sys.argv[0] = re.sub(r"(-script\.pyw|\.exe)?$", "", sys.argv[0])
    sys.exit(launch())
    