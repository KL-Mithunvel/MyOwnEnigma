"""Print what to type and what the lamps should show for each preset, for bench bring-up.

    python tools/bringup_expected.py                   # default test message and start window
    python tools/bringup_expected.py --text ENIGMA --start QWE

For every preset in config.yaml it shows: the preset switch setting (sw[1:0]), the three start letters to
type in SETUP mode, the message, the expected lamp sequence, and the rotor window after each key press
(use btn[1..3] to read the window on the lamp board). Also prints the published-vector check.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
import enigma_ref as ref  # noqa: E402


def window(machine: ref.Enigma) -> str:
    return "".join(ref.to_letter(p) for p in machine.pos)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("--text", default="HELLOWORLD", help="message to type (letters only)")
    parser.add_argument("--start", default="AAA", help="three start letters typed in setup mode")
    args = parser.parse_args()
    presets = yaml.safe_load((ROOT / "config.yaml").read_text(encoding="utf-8"))["presets"]

    print("Published check (preset 0, start AAA): type A five times -> lamps B D Z G O")
    published = ref.make_machine(["I", "II", "III"], "AAA", "AAA").encrypt("AAAAA")
    assert published == "BDZGO", "reference model no longer matches the published vector"
    print()
    for idx, preset in enumerate(presets):
        machine = ref.make_machine(preset["rotors"], preset["rings"], args.start, preset["reflector"], preset["plugs"])
        sw = f"sw[1:0] = {idx >> 1}{idx & 1}"
        print(f"=== Preset {idx}: {preset['name']}  ({sw}) ===")
        print(f"  rotors {'-'.join(preset['rotors'])}  rings {preset['rings']}  reflector {preset['reflector']}  "
              f"plugs [{preset['plugs'] or 'none'}]")
        print(f"  1. set {sw}, switch sw[2] ON (setup), type {' '.join(args.start.upper())}, switch sw[2] OFF")
        print(f"  2. type the message; expected lamps and rotor window after each key:")
        rows = []
        for ch in args.text.upper():
            if ch.isalpha():
                out = ref.to_letter(machine.encrypt_letter(ref.to_int(ch)))
                rows.append(f"{ch}->{out} [{window(machine)}]")
        for i in range(0, len(rows), 5):
            print("     " + "   ".join(rows[i:i + 5]))
        print()


if __name__ == "__main__":
    main()
