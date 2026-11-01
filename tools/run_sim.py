"""Run the whole Verilog verification flow with Icarus Verilog.

    python tools/run_sim.py --all          # generate headers + vectors, lint, run every testbench
    python tools/run_sim.py --tb tb_enigma_core --vcd     # one testbench, with a waveform dump

Steps: (1) gen_tables.py  (2) gen_vectors.py  (3) compile each sim/tb_*.v with all rtl/*.v at -Wall
(4) run it with vvp and require a final "PASS". Exit code is non-zero on any failure, so this is the
single command used before every commit. Waveforms go to sim/build/*.vcd (git-ignored).
"""

from __future__ import annotations

import argparse
import os
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BUILD = ROOT / "sim" / "build"
IVERILOG_FALLBACK_DIRS = [Path("C:/iverilog/bin"), Path("C:/Program Files/iverilog/bin")]


def find_tool(name: str) -> str:
    found = shutil.which(name)
    if found:
        return found
    for directory in IVERILOG_FALLBACK_DIRS:
        for candidate in (directory / name, directory / f"{name}.exe"):
            if candidate.exists():
                return str(candidate)
    raise SystemExit(f"{name} not found. Install Icarus Verilog: winget install Icarus.Verilog")


def run(cmd: list[str], **kwargs) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, cwd=ROOT, text=True, capture_output=True, **kwargs)


def run_testbench(tb: Path, iverilog: str, vvp: str, vcd: bool) -> bool:
    name = tb.stem
    out = BUILD / f"{name}.vvp"
    rtl = sorted(str(p) for p in (ROOT / "rtl").glob("*.v"))
    compile_cmd = [iverilog, "-g2012", "-Wall", "-I", "rtl", "-s", name, "-o", str(out), str(tb), *rtl]
    result = run(compile_cmd)
    warnings = [line for line in (result.stdout + result.stderr).splitlines() if line.strip()]
    if result.returncode != 0:
        print(f"[FAIL] {name}: compile error")
        print("\n".join(warnings))
        return False
    # -Wall warnings from our own sources (not from generated headers' benign width notes) are shown.
    if warnings:
        print(f"[warn] {name}: {len(warnings)} compiler warning(s)")
        print("\n".join("    " + w for w in warnings[:15]))

    sim_cmd = [vvp, str(out)] + (["+VCD"] if vcd else [])
    result = run(sim_cmd, timeout=600)
    text = result.stdout
    # Ignore vvp's own "$finish called at ..." trailer; the testbench's verdict is its last line.
    lines = [line for line in text.splitlines() if line.strip() and "$finish called" not in line]
    passed = (result.returncode == 0 and bool(lines) and lines[-1].strip() == "PASS"
              and not any(line.strip().startswith(("FAIL", "MISMATCH")) for line in lines))
    print(f"[{'PASS' if passed else 'FAIL'}] {name}")
    if not passed or "-v" in sys.argv:
        print("\n".join("    " + line for line in lines[-25:]))
    return passed


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("--all", action="store_true", help="run every sim/tb_*.v (default)")
    parser.add_argument("--tb", action="append", help="run only this testbench (name without .v)")
    parser.add_argument("--vcd", action="store_true", help="dump waveforms (+VCD)")
    parser.add_argument("-v", action="store_true", help="always print simulator output")
    args = parser.parse_args()

    iverilog, vvp = find_tool("iverilog"), find_tool("vvp")
    BUILD.mkdir(parents=True, exist_ok=True)
    env_py = sys.executable
    for script in ("gen_tables.py", "gen_vectors.py"):
        result = run([env_py, str(ROOT / "tools" / script)])
        if result.returncode != 0:
            print(result.stdout + result.stderr)
            return 1
        print(result.stdout.strip().replace("\n", " | "))

    benches = sorted((ROOT / "sim").glob("tb_*.v"))
    if args.tb:
        benches = [b for b in benches if b.stem in args.tb]
        if not benches:
            print(f"no testbench matches {args.tb}")
            return 1
    results = [run_testbench(tb, iverilog, vvp, args.vcd) for tb in benches]
    print(f"\n{sum(results)}/{len(results)} testbenches passed")
    return 0 if all(results) else 1


if __name__ == "__main__":
    sys.exit(main())
