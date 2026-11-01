
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
