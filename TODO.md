# TODO

Legend: 🔴 bug | 🟡 incomplete | 🟢 not started | ✅ done. Plan details: `docs/PLAN.md`.

## In Progress
- [ ] Phase 4 — quality gates (lint, coverage checks, mutation sanity, pytest wrapper)

## Not Started
- [ ] Phase 5 — bring-up kit (`docs/BRINGUP.md`)
- [ ] Phase 6 — showcase artifact (interactive simulator + project story)
- [ ] Phase 7 — hardware verification by the owner (keyboard + lamp board)
- [ ] Backlog: Morse output, UART to PC, keyboard-entered plugboard/rotor settings, 7-segment window, M4

## Done
- [x] Phase 3 — `enigma_top` (presets, setup mode, window display on lamps, reload, status LEDs), `constraints/arty_s7_enigma.xdc`, full-system testbench (963 checks)
- [x] Phase 2 — `key_scanner` (settle, multi-frame debounce, ghost/multi-key rejection) + `lamp_driver` (registered outputs, min on-time); 166 + 138 checks pass
- [x] Phase 1 — Verilog core (rotors I–V, reflectors B/C, ring settings, double-step, 10-pair plugboard); 262 model vectors + directed tests pass (`tools/run_sim.py`)
- [x] Phase 0 — foundation and documentation (commit e30a55d)
- [x] Reference model + pytest with published vectors (AAAAA → BDZGO, 26×A, double-step sequence)
- [x] `config.yaml` with key matrix extracted from the legacy working code
