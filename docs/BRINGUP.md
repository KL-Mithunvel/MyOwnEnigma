# Hardware Bring-Up Guide (Phase 7)

For the first time the design meets the real Arty S7-50, keyboard and lamp board. Everything here has
been verified **in simulation only**. Work through the stages in order; stop at the first failure, fix it
on the dev machine (edit `config.yaml` / RTL → `python tools/run_sim.py --all` → rebuild) and repeat.
Record results in the table at the bottom and in `Claude_log.md`.

## 0. Before you touch the board

On the dev machine, all of these must pass:

```bash
source venv/Scripts/activate
python -m pytest tests -q            # 65 tests
python tools/run_sim.py --all        # 4 testbenches
python tools/mutation_check.py       # every injected bug caught
python tools/synth_check.py          # Yosys: no latches, ~440 LUTs
python tools/bringup_expected.py     # prints what to type and the lamps to expect (keep it next to you)
```

Hardware assumptions to confirm against `schematic/` (they come from the project documents, not from a
measurement):

| Assumption | Where it came from | If wrong |
|-----------|--------------------|----------|
| Keyboard: mux select on `ck_io0..3`, rows on `ck_io5..8` (high = pressed) | legacy `test.v` (worked: keys → lamps A→A) | edit `config.yaml → keyboard` |
| `ck_io4` is the keyboard CD74HC4067 enable, active low (driven low by `enigma_top`) | early `keyboard` experiment in `test.v`; schematic label `EN` | remove the `ck_io4` assignment if it goes elsewhere |
| 10 kΩ resistors R1–R4 in the keyboard schematic are row pull-downs | KiCad schematic | if rows float, add `set_property PULLDOWN true` on `ck_io5..8` in the XDC |
| Lamp board takes `o_lb0..4` (+ `o_lb4N`); code table A–M → 0–12, N–Z → 16–28 | legacy `test.v`; poster | edit `config.yaml → lamp` |
| The lamp board has its own 74AHC1G04 inverters (schematic) | KiCad `schematicsstest!` | `o_lb4N` may be redundant; harmless |
| All board I/O is 3.3 V | Arty header | never connect 5 V to `ck_io` inputs |

## 1. Build the bitstream

Command line (from the repository root, with Vivado on the PATH):

```bash
python tools/gen_tables.py
vivado -mode batch -source tools/vivado_build.tcl
```

Or in the GUI: new RTL project, part **xc7s50csga324-1**, add `rtl/*.v` and `rtl/*.vh` (file type
*Verilog Header*; add `rtl` to the include directories), add `constraints/arty_s7_enigma.xdc`, set top
**enigma_top**, run synthesis, implementation, generate bitstream.

Pass criteria for the build (`build/timing.rpt`, `build/utilization.rpt`):

| Check | Expect |
|-------|--------|
| Timing summary: WNS (worst negative slack) | ≥ 0 ns at 100 MHz (if not, tell the dev machine side: the rotor stage can be split further) |
| Utilization | about 430–600 LUTs, about 400 FFs, 0 BRAM, 0 DSP |
| CRITICAL WARNINGs | none about unconstrained or unplaced ports |
| Latch warnings | none |
| `sw[3]` / `ck_a0` | not used (see `docs/HARDWARE.md`) |

Program the board (`... -tclargs program` or Hardware Manager).

## 2. Bench stages

Use `python tools/bringup_expected.py` for the expected letters of each preset.

| # | Stage | Do | Expect | If not |
|---|-------|----|--------|--------|
| S0 | Alive | Program the board | `led[3]` blinks about 1 Hz; RGB0 red; RGB1 green | bitstream not loaded / clock pin |
| S1 | Switches and buttons | Move `sw[1:0]`; flip `sw[2]` | RGB0 red → green → blue → white for 00, 01, 10, 11; `sw[2]` ON lights `led[1]` and RGB1 blue | switch pin map in the XDC |
| S2 | Lamp board alone | Hold `btn[1]+btn[2]+btn[3]` together | Lamps sweep A, B, C … Z (300 ms each), then repeat; releasing turns all off | wrong mux code → edit `lamp.codes`; two letters lit → `o_lb4N` wiring |
| S3 | Rotor window on the lamps | Hold `btn[1]` / `btn[2]` / `btn[3]` one at a time | Lamp A each time (all rotors start at A) | window display path |
| S4 | Keyboard alone | `sw[2]` ON (setup), press each key A … Z | each key lights **its own letter** (the old A→A test); `led[0]` lit while held | wrong key → edit `keyboard.keys`; nothing → check EN / pull-downs; two letters → bounce or ghosting |
| S5 | Published Enigma vector | Preset 00. Setup: type A A A, `sw[2]` OFF. Type A five times | lamps **B D Z G O** | wrong → compare with `bringup_expected.py`; see troubleshooting |
| S6 | Decryption | `btn[0]` (reload start), type B D Z G O | lamps **A A A A A** | reload / reciprocity |
| S7 | Stepping and double-step | Setup: type A D U, `sw[2]` OFF. Type A; hold `btn[1..3]` after each key | window reads ADV, then AEW, then BFX, then BFY (the middle rotor steps twice) | notch / stepping |
| S8 | All presets | For `sw[1:0]` = 01, 10, 11: setup start window AAA, type HELLOWORLD | lamps exactly as printed by `bringup_expected.py` | per-preset wiring/plugs/rings |
| S9 | Abuse | Hold a key (no repeat); press two keys at once (ignored); type quickly | one letter per press; no ghost letters; no lost letters at typing speed | tune `debounce_frames`, `scan_dwell_us` in `config.yaml` |
| S10 | Long run | Type 100+ letters, then decrypt with `btn[0]` | decrypted text equals the original | accumulated stepping error |

## 3. Troubleshooting

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| No key ever registers | `EN` not enabled; rows floating; mux select wrong | check `ck_io4` / EN; add row pull-downs; probe `ck_io0..3` for the scan pattern |
| Keys register as the wrong letters | key matrix differs from `config.yaml` | measure the {column,row} of each key and edit `keyboard.keys`, regenerate, re-simulate |
| Letters appear twice | debounce too short | raise `timing.debounce_frames` or `scan_dwell_us` |
| Letters from keys in one column are missed | mux settle time too short | raise `timing.scan_dwell_us` |
| Wrong lamp lights (right group, wrong letter) | lamp channel wiring differs | edit `lamp.codes` |
| Letters N–Z light the wrong lamp / two lamps | second-mux enable | check `o_lb4` / `o_lb4N` and the 74AHC1G04 |
| `led[2]` / RGB1 red | invalid plugboard in a preset | fix `config.yaml → presets`; the generator also rejects it |
| Encryption wrong but keyboard/lamps fine | cannot be the I/O: compare with `tools/enigma_ref.py` and re-run simulation with the same settings | report the exact keys typed and lamps seen |
| Timing fails in Vivado | rotor stage too deep | split the stage (dev machine), re-simulate |

## 4. Results (fill in on the bench)

**Overall (2026-11-02):** the owner tested the build on the real Arty S7 with the keyboard and lamp board and reported that it works. Per-stage dates, the Vivado WNS and LUT count, and any notes have not been recorded yet; fill in the table below.

| Stage | Date | Pass / fail | Notes |
|-------|------|-------------|-------|
| Vivado build (WNS, LUTs) | | | |
| S0 | | | |
| S1 | | | |
| S2 | | | |
| S3 | | | |
| S4 | | | |
| S5 | | | |
| S6 | | | |
| S7 | | | |
| S8 | | | |
| S9 | | | |
| S10 | | | |
