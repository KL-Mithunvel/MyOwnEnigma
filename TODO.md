# TODO

Legend: 🔴 bug | 🟡 incomplete | 🟢 not started | ✅ done. Plan details: `docs/PLAN.md`.

## In Progress
- [ ] Phase 2 — key scanner + lamp driver + testbenches

## Not Started
- [ ] Phase 3 — top level (presets, setup mode, window display), XDC, system testbench
- [ ] Phase 4 — quality gates (lint, coverage checks, one-command run, pytest wrapper)
- [ ] Phase 5 — bring-up kit (`docs/BRINGUP.md`)
- [ ] Phase 6 — showcase artifact (interactive simulator + project story)
- [ ] Phase 7 — hardware verification by the owner (keyboard + lamp board)
- [ ] Backlog: Morse output, UART to PC, keyboard-entered plugboard/rotor settings, 7-segment window, M4

## Done
- [x] Phase 1 — Verilog core (rotors I–V, reflectors B/C, ring settings, double-step, 10-pair plugboard); 262 model vectors + directed tests pass (`tools/run_sim.py`)
- [x] Phase 0 — foundation and documentation (commit e30a55d)
- [x] Reference model + pytest with published vectors (AAAAA → BDZGO, 26×A, double-step sequence)
- [x] `config.yaml` with key matrix extracted from the legacy working code
