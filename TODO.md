# TODO

Legend: 🔴 bug | 🟡 incomplete | 🟢 not started | ✅ done. Plan details: `docs/PLAN.md`.

## In Progress
- [ ] Phase 0 — foundation and documentation

## Not Started
- [ ] Phase 1 — Verilog core (rotors, reflector, plugboard) + core testbench vs. golden model
- [ ] Phase 2 — key scanner + lamp driver + testbenches
- [ ] Phase 3 — top level (presets, setup mode, window display), XDC, system testbench
- [ ] Phase 4 — quality gates (lint, coverage checks, one-command run, pytest wrapper)
- [ ] Phase 5 — bring-up kit (`docs/BRINGUP.md`)
- [ ] Phase 6 — showcase artifact (interactive simulator + project story)
- [ ] Phase 7 — hardware verification by the owner (keyboard + lamp board)
- [ ] Backlog: Morse output, UART to PC, keyboard-entered plugboard/rotor settings, 7-segment window, M4

## Done
- [x] Reference model + pytest with published vectors (AAAAA → BDZGO, 26×A, double-step sequence)
- [x] `config.yaml` with key matrix extracted from the legacy working code
