
## 2026-11-01 — Phase 3: top level, UI and system test
- `rtl/enigma_top.v` + `rtl/sync_debounce.v`: presets on sw[1:0], keyboard-driven SETUP mode on sw[2] (typed letters become the start window, echoed on the
  lamps), btn[0] reload, btn[1..3] show the rotor window letters on the lamp board (works with no display), status LEDs, power-on reset.
  `sw[3]` deliberately unused (1.35 V SSTL135 bank).
- Generator change: presets emitted as a function + `assign` instead of `always @*` (same time-0 X hazard as the plugboard; avoided before it bit).
- `constraints/arty_s7_enigma.xdc`: only the pins used; all 32 pin/standard pairs cross-checked against the Digilent master XDC by script (0 mismatches).
- `sim/tb_enigma_top.v`: behavioural diode-matrix keyboard + lamp decoder around the whole design; 12 model vectors (3 per preset x 4 presets) through
  setup mode -> typing -> window display -> reload. 963 checks, 0 errors. `run_sim.py --all` 4/4.
- Testbench bug (mine): `~o_lb4` on a 1-bit wire passed to an integer task port widens to 32 bits (-1/-2) and produced 288 false errors; fixed the check, not the design.
- Tooling note: on this Windows machine Python's default file encoding is cp1252; always pass `encoding="utf-8"` when writing docs that contain arrows or other non-ASCII.

## 2026-11-01 — Phase 4: quality gates and design optimisation
- Added `tools/mutation_check.py`: injects 18 realistic bugs (no double-step, ring ignored, wrong notch, ghost-key rejection removed, lb4N not inverted, ...)
  into a temp copy of `rtl/`; all 18 are caught by a testbench. This proves the testbenches can fail, not only pass.
- Added `tools/synth_check.py` (Yosys via `pip install yowasp-yosys`, `synth_xilinx`): found a real problem the simulation could not.
  First result: **7,190 LUTs (22% of the XC7S50)** for a tiny design. Causes: (1) plugboard built a full 26-entry map; (2) ROM lookups written as a
  130-bit barrel shift (`w[idx*5 +: 5]`); (3) the rotor datapath instantiated six times though stages run one at a time; (4) 32-bit counters everywhere.
  Fixes: priority-compare plugboard; ROMs emitted as flat `case ({sel, idx})`; ONE shared rotor unit selected per state; `clog2`-sized counters.
  Result: **422 LUTs (1.3%), 341 FFs, 0 BRAM/DSP, no latches, no warnings**.
- Timing margin without Vivado available: each rotor stage is now two clocks (add offset; ROM lookup + remove offset) so no clock chains add+ROM+subtract.
  Letter latency 10 -> 15 clocks (150 ns). Real timing must still be confirmed in Vivado (Phase 7 checklist).
- Added tests: config vs the legacy `test.v` tables (key matrix and lamp codes are identical to what worked on the real keyboard), XDC pins vs the Digilent
  master and vs `enigma_top` ports, generated headers in sync, vector coverage (every rotor in every slot, both reflectors, 0-10 plugs, >=20 double-steps),
  static RTL rules (no `$`, no delays, no `initial`, no `always @*`, one module per file), and wrappers for the simulations and synthesis. 63+ tests pass.
- Repeated tooling issue: multi-line strings with `
` inside bash heredocs got turned into real newlines; repaired with the Edit tool. Use Edit for multi-line text.
