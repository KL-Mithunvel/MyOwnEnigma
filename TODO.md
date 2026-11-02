# TODO

Legend: 🔴 bug | 🟡 incomplete | 🟢 not started | ✅ done. Plan details: `docs/PLAN.md`.

## In Progress
- [x] Phase 7 — hardware bench test done by the owner (keyboard + lamp board): works (2026-11-02). Per-stage numbers and Vivado WNS not yet recorded in `docs/BRINGUP.md`
- [ ] Add the owner's own hardware photos and KiCad schematic images to the showcase when supplied

## Not Started
- [ ] Backlog: Morse output, UART to PC, keyboard-entered plugboard/rotor settings, 7-segment window, M4

## Done
- [x] Phase 6 — showcase artifact published (private): https://claude.ai/artifact/GVLsJr9zbRmiKx9r9xESwr — built by `tools/build_showcase.py` from `showcase/template.html`; share from the page's Share menu
- [x] Phase 5 — bring-up kit: `docs/BRINGUP.md` (stages S0–S10, troubleshooting, results table), `tools/vivado_build.tcl`, `tools/bringup_expected.py`, lamp self-test (hold btn[1..3]), `ck_io4` mux enable driven low, schematic facts recorded
- [x] Phase 4 — quality gates: mutation check (18/18), Yosys synthesis gate (7,190 → 422 LUTs after sharing the rotor unit and using ROM-style tables), two-phase rotor stage for timing margin, pytest suite (config vs legacy test.v, XDC vs top ports, generated-file sync, vector coverage, static RTL rules)
- [x] Phase 3 — `enigma_top` (presets, setup mode, window display on lamps, reload, status LEDs), `constraints/arty_s7_enigma.xdc`, full-system testbench (963 checks)
- [x] Phase 2 — `key_scanner` (settle, multi-frame debounce, ghost/multi-key rejection) + `lamp_driver` (registered outputs, min on-time); 166 + 138 checks pass
- [x] Phase 1 — Verilog core (rotors I–V, reflectors B/C, ring settings, double-step, 10-pair plugboard); 262 model vectors + directed tests pass (`tools/run_sim.py`)
- [x] Phase 0 — foundation and documentation (commit e30a55d)
- [x] Reference model + pytest with published vectors (AAAAA → BDZGO, 26×A, double-step sequence)
- [x] `config.yaml` with key matrix extracted from the legacy working code
