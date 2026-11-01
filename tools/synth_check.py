"""Synthesis sanity check with Yosys (targeting the Xilinx 7-series, like the Arty S7's Spartan-7).

    python tools/synth_check.py

Not a replacement for Vivado, but it catches the problems that matter before touching hardware:
unsynthesizable constructs, inferred latches, missing drivers, and an unexpectedly large design.
Prints a resource summary against the XC7S50 (32,600 LUTs, 65,200 FFs). Exit code is non-zero if
Yosys reports an error/warning about the design or infers a latch. Uses the `yowasp-yosys` pip package
(`pip install yowasp-yosys`) or a native `yosys` on PATH. The log is written to sim/build/synth.log.
"""

from __future__ import annotations

import re
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LOG = ROOT / "sim" / "build" / "synth.log"
TOP = "enigma_top"
SOURCES = ["plugboard", "enigma_core", "key_scanner", "lamp_driver", "sync_debounce", "enigma_top"]
DEVICE = {"LUT": 32600, "FF": 65200}  # XC7S50
MAX_LUT_PERCENT = 25                  # budget: the Enigma should be tiny


def find_yosys() -> list[str]:
    for name in ("yosys", "yowasp-yosys"):
        found = shutil.which(name)
        if found:
            return [found]
    scripts = Path(sys.executable).parent
    for candidate in (scripts / "yowasp-yosys.exe", scripts / "yowasp-yosys"):
        if candidate.exists():
            return [str(candidate)]
    raise SystemExit("Yosys not found. Install it with: pip install yowasp-yosys")


def main() -> int:
    LOG.parent.mkdir(parents=True, exist_ok=True)
    files = " ".join(f"rtl/{name}.v" for name in SOURCES)
    script = (f"read_verilog -sv -I rtl {files}; hierarchy -check -top {TOP}; "
              f"synth_xilinx -family xc7 -flatten -top {TOP}; stat")
    result = subprocess.run(find_yosys() + ["-q", "-l", "sim/build/synth.log", "-p", script], cwd=ROOT, text=True,
                            capture_output=True)
    log = LOG.read_text(encoding="utf-8", errors="replace") if LOG.exists() else ""
    problems = []
    if result.returncode != 0:
        problems.append(f"yosys failed:\n{result.stderr[-1500:]}")
    # "No latch inferred" is the good message; a real one reads "Latch inferred for signal ..."
    problems += [line.strip() for line in log.splitlines() if re.search(r"(?<!No )latch inferred", line, re.I)]
    # Ignore the harmless lexer notice about Yosys's own abc9 library files.
    problems += [line.strip() for line in log.splitlines()
                 if re.match(r"\s*(Warning|ERROR)", line) and "abc9" not in line]

    # Resource summary from the final (flattened) top-level statistics.
    last_stat = log[log.rindex("=== " + TOP + " ==="):] if ("=== " + TOP + " ===") in log else ""
    counts: dict[str, int] = {}
    for count, cell in re.findall(r"^\s+(\d+)\s+(LUT\d|FD\w+|CARRY4|RAMB\w+|RAM\d+\w*|DSP48E1|MUXF\d|BUFG|IBUF|OBUF)\s*$",
                                  last_stat, flags=re.M):
        counts[cell] = counts.get(cell, 0) + int(count)
    luts = sum(v for k, v in counts.items() if k.startswith("LUT"))
    ffs = sum(v for k, v in counts.items() if k.startswith("FD"))
    print(f"Synthesis ({TOP}, Xilinx 7-series): {luts} LUTs ({100 * luts / DEVICE['LUT']:.1f}% of XC7S50), "
          f"{ffs} FFs ({100 * ffs / DEVICE['FF']:.1f}%), CARRY4 {counts.get('CARRY4', 0)}, "
          f"BRAM {sum(v for k, v in counts.items() if k.startswith('RAMB'))}, DSP {counts.get('DSP48E1', 0)}")
    if luts == 0:
        problems.append("could not read resource statistics from the log")
    if 100 * luts / DEVICE["LUT"] > MAX_LUT_PERCENT:
        problems.append(f"design uses more than {MAX_LUT_PERCENT}% of the device LUTs")
    for problem in problems:
        print("  PROBLEM:", problem)
    print("SYNTH OK" if not problems else "SYNTH FAILED")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
