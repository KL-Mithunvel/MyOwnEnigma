# Claude Log

## 2026-11-01 — Revive the project: plan, golden model, docs
- Cloned the template library (`claude/`, git-ignored) and copied `CLAUDE-COMMON.md` / `PROJ_STARTER.md` into
  `.CLAUDE/`; wrote the project brief `.CLAUDE/CLAUDE.md`.
- Read every document and PDF: README, team slides (24 pp), poster, Arty S7 schematic, XDC, KiCad zip, CAD
  READMEs, legacy `test.v`. Findings recorded in `docs/HARDWARE.md` and the Known Technical Debt list.
  - Correction: multiplexers are CD74HC4067 (16-ch), not 74HC4051 as the README said.
  - `sw[3]` is in the 1.35 V DDR bank (SSTL135) → not used as a user input.
  - Poster/slides mention Morse output; not implemented → backlog.
- No hardware available during the build; owner will verify on the real keyboard + lamp board afterwards.
  Everything is verified in simulation against the Python golden model.
- Installed Icarus Verilog 12 via winget (`C:\iverilog\bin`, not on PATH by default).
- Created venv, `requirements.txt`, `.gitignore`; extracted the KiCad zip into `schematic/` (kept the zip).
- Added `tools/enigma_ref.py` + `tests/test_enigma_ref.py`. Published vectors pass (AAAAA→BDZGO, 26×A).
  One of my own tests was weak (A→B unchanged by an AB plug) and was rewritten.
- Wrote `docs/PLAN.md` (phases 0–7), `ENIGMA_SPEC.md`, `HARDWARE.md`.
- Decision: one commit per phase, per the owner's instruction.

## 2026-11-01 — Phase 1: Verilog core verified against the golden model
- Added `tools/gen_tables.py` (rotor/reflector ROMs, key decode, lamp encode, presets -> `rtl/*.vh` from `config.yaml` + `enigma_ref.py`),
  `rtl/enigma_math.vh`, `rtl/plugboard.v`, `rtl/enigma_core.v`, `tools/gen_vectors.py`, `sim/tb_enigma_core.v`, `tools/run_sim.py`.
- Design: one shared datapath stage per clock (10 clocks/letter) instead of a 100 MHz-critical combinational chain -> easy timing on the Arty.
- Result: `python tools/run_sim.py --all` -> PASS, 10,759 checks, 262 vectors (random machines, stepping edge cases, a 700-letter run, all rotors/reflectors, 0-10 plugs), `-Wall` clean.
- Bug found and fixed in simulation: the plugboard used `always @*`, which never fires at time 0 when inputs do not change -> X outputs in iverilog. Rewritten as a function + continuous assign (safe in sim and synthesis).
- Runner bug fixed: vvp prints a `$finish called` trailer after PASS; the runner now ignores it.

## 2026-11-01 — Phase 2: keyboard scanner and lamp driver
- `rtl/key_scanner.v`: column dwell (SCAN_TICKS) for mux settling, one sample per column, frame-based debounce
  (DEBOUNCE_FRAMES), frames with two different keys or an unknown row pattern are ignored (no ghost letters), release on an empty frame.
  Replaces the legacy design that sampled against a free-running counter with no settle time.
- `rtl/lamp_driver.v`: registered mux-select outputs (no glitching lamps), minimum on-time so quick taps are visible, lit while held.
- Testbenches: `tb_key_scanner` (behavioural diode-matrix model: all 26 keys, hold, release, short tap, rollover, junk pattern, key change, reset) and
  `tb_lamp_driver` (expected codes hardcoded independently of the generated table). All pass; `run_sim.py --all` 3/3.
- Mistake caught: `before` is a SystemVerilog reserved word (compile error); renamed.
