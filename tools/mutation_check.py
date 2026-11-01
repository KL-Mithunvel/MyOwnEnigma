"""Mutation check: prove the testbenches can actually fail.

    python tools/mutation_check.py

Each mutation applies one realistic bug to a temporary copy of rtl/ (missing double-step, ring
setting ignored, wrong notch, ghost-key rejection removed, lamp enable not inverted, ...) and runs
the testbenches. A mutation is KILLED if at least one testbench fails, SURVIVED if all still pass.
A surviving mutation means a gap in the tests. Exit code is non-zero if any mutation survives.
Run `python tools/run_sim.py --all` first so sim/build/vectors.txt exists.
"""

from __future__ import annotations

import shutil
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
import run_sim  # noqa: E402

# (rtl file, text that must occur exactly once, replacement, description)
MUTATIONS = [
    ("enigma_core.v", "if (mid_at_notch || right_at_notch) pos_m", "if (right_at_notch) pos_m",
     "no double-step of the middle rotor"),
    ("enigma_core.v", "pos_l <= add26(pos_l, 5'd1);", "pos_l <= pos_l;", "left rotor never steps"),
    ("enigma_core.v", "pos_r <= add26(pos_r, 5'd1);", "pos_r <= pos_r;", "right rotor never steps"),
    ("enigma_core.v", "reflect(reflector_sel, sig)", "reflect(1'b0, sig)", "reflector select ignored"),
    ("enigma_core.v", "lamp_code <= plug_sig;", "lamp_code <= sig;", "plugboard skipped on the way out"),
    ("enigma_core.v", "sig   <= plug_sig;", "sig   <= sig;", "plugboard skipped on the way in"),
    ("plugboard.v", "swap = lb;", "swap = la;", "plugboard swaps a letter with itself"),
    ("enigma_core.v", "sub26(u_pos, u_ring)", "u_pos", "ring setting ignored"),
    ("enigma_core.v", "sub26(u_wired, u_shift)", "u_wired", "rotor offset not removed after the lookup"),
    ("enigma_tables.vh", "3'd2: rotor_notch = 5'd21;", "3'd2: rotor_notch = 5'd20;", "wrong notch on rotor III"),
    ("plugboard.v", "used[la] || used[lb]", "1'b0", "plugboard letter-reuse not detected"),
    ("key_scanner.v", "else if (n_code != decoded)", "else if (1'b0)", "two-key (ghost) rejection removed"),
    ("key_scanner.v", "n_stable == DEBOUNCE_FRAMES &&", "n_stable == 8'd1 &&", "debounce reduced to one frame"),
    ("lamp_driver.v", "on_count <= MIN_ON_TICKS;", "on_count <= 32'd0;", "lamp minimum on-time removed"),
    ("lamp_driver.v", "lb4N <= ~(lit ? code[4] : IDLE[4]);", "lb4N <= (lit ? code[4] : IDLE[4]);",
     "lb4N not inverted"),
    ("enigma_top.v", "{setup_pos[9:0], key_code}", "{key_code, setup_pos[14:5]}", "setup window shifts the wrong way"),
    ("enigma_top.v", ".load(setup_done | reload_rise)", ".load(setup_done)", "reload button disabled"),
    ("enigma_top.v", "lt_letter + 5'd1", "lt_letter + 5'd2", "lamp self-test skips letters"),
    ("enigma_top.v", "b_left ? pos_out[14:10]", "b_left ? pos_out[4:0]", "left window button shows the wrong rotor"),
]
FAST_FIRST = ["tb_lamp_driver", "tb_key_scanner", "tb_enigma_core", "tb_enigma_top"]


def main() -> int:
    iverilog, vvp = run_sim.find_tool("iverilog"), run_sim.find_tool("vvp")
    run_sim.BUILD.mkdir(parents=True, exist_ok=True)
    benches = [ROOT / "sim" / f"{name}.v" for name in FAST_FIRST]
    survivors = []
    for rtl_file, old, new, description in MUTATIONS:
        with tempfile.TemporaryDirectory() as tmp:
            tmp_rtl = Path(tmp) / "rtl"
            shutil.copytree(ROOT / "rtl", tmp_rtl)
            target = tmp_rtl / rtl_file
            text = target.read_text(encoding="utf-8")
            if text.count(old) != 1:
                print(f"[ERROR] {rtl_file}: pattern {old!r} found {text.count(old)} times (update mutation list)")
                return 2
            target.write_text(text.replace(old, new), encoding="utf-8", newline="\n")
            killed_by = None
            for tb in benches:
                if not run_sim.run_testbench(tb, iverilog, vvp, False, rtl_dir=tmp_rtl, quiet=True):
                    killed_by = tb.stem
                    break
        status = f"KILLED by {killed_by}" if killed_by else "SURVIVED  <-- test gap"
        print(f"[{'ok' if killed_by else '!!'}] {rtl_file:16s} {description:45s} {status}")
        if not killed_by:
            survivors.append(description)
    print(f"\n{len(MUTATIONS) - len(survivors)}/{len(MUTATIONS)} mutations killed")
    return 1 if survivors else 0


if __name__ == "__main__":
    sys.exit(main())
