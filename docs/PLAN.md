# Build Plan — FPGA Enigma (Arty S7-50)

Goal: turn the half-built 2024 student prototype into a **correct, verified, hardware-ready**
Verilog Enigma (3 rotors + plugboard), then a shareable showcase for hiring managers,
admissions committees and friends.

**Working rules for this plan**

- No hardware is available during the build. Everything is verified on the dev machine in
  simulation first (CLAUDE-COMMON → Deployment Model). Hardware verification is a separate,
  later step done by the owner (Phase 7 checklist).
- The Python reference model (`tools/enigma_ref.py`) is the golden model. The Verilog is correct
  only when it matches the model bit-for-bit on directed tests *and* random vectors.
- Every tunable lives in `config.yaml`; Verilog headers are generated from it.
- One git commit per phase. Docs, TODO.md and Claude_log.md are updated in the same commit.
- `test.v` (the original) is never edited; it is the historical record.

## Phase 0 — Foundation and documentation
- **Goal:** a clean, documented project the next phases can build on.
- **Steps:** `.gitignore`, `requirements.txt`, venv; extract the KiCad zip; reference model +
  pytest; `config.yaml`; docs (`ENIGMA_SPEC.md`, `HARDWARE.md`, this plan); `.CLAUDE/` project
  brief; correct README (status, multiplexer part number); fill empty sub-READMEs; TODO + log.
- **Files:** `.CLAUDE/*`, `docs/*`, `tools/enigma_ref.py`, `tests/test_enigma_ref.py`, `config.yaml`,
  READMEs.
- **Done when:** `pytest` passes including published Enigma test vectors.

## Phase 1 — Verilog core: rotors, reflector, plugboard
- **Goal:** a synthesizable, correct `enigma_core` verified against the model.
- **Steps:** `tools/gen_tables.py` (wiring ROMs from the model → `rtl/enigma_tables.vh`);
  `rtl/plugboard.v`, `rtl/enigma_core.v` (stepping incl. double-step, ring settings, rotors I–V,
  reflectors B/C, one shared datapath stage per clock); `tools/gen_vectors.py` +
  `sim/tb_enigma_core.v` (directed vectors + random vectors from the model); `tools/run_sim.py`.
- **Done when:** all directed and random vectors pass in Icarus Verilog; AAAAA → BDZGO.

## Phase 2 — Keyboard scanner and lamp driver
- **Goal:** replace the racy, hard-coded `test.v` input/output logic with robust blocks.
- **Steps:** `rtl/key_scanner.v` (column scan, settle, multi-frame debounce, one-key-at-a-time,
  press/release events); `rtl/lamp_driver.v` (letter → 4067 code, minimum on-time, lit while key
  held); testbenches with a simulated diode-matrix keyboard model.
- **Done when:** every one of the 26 keys decodes to the right letter and lamp code in simulation;
  chatter and two-key presses are rejected.

## Phase 3 — Top level and user interface
- **Goal:** `enigma_top` for the Arty S7 that works with only the keyboard and lamp board attached.
- **Steps:** presets on `sw[1:0]`; **setup mode** on `sw[2]` where typed letters set the start
  window; `btn[0]` reload start position; `btn[1..3]` show left/middle/right window letter *on the
  lamp board* (no display needed); status LEDs and heartbeat; plug-error indicator;
  `constraints/arty_s7_enigma.xdc`; full-system testbench with waveform dump.
- **Done when:** the system test types a message via the simulated keyboard and the lamp codes match
  the model for all presets.

## Phase 4 — Quality gates
- **Goal:** raise the engineering value of the code.
- **Steps:** lint at `-Wall`; check for latches / unintended X; gate-level-friendly coding review;
  coverage-style checks (all rotors, all reflectors, every notch, plugboard 0–10 pairs, all keys);
  CI-style one-command `tools/run_sim.py --all`; pytest wrapper so `pytest` runs the RTL tests too.
- **Done when:** one command runs everything and prints PASS; no lint warnings.

## Phase 5 — Documentation polish and bring-up kit
- **Goal:** the owner can verify on real hardware quickly and without guessing.
- **Steps:** `docs/BRINGUP.md` (stage-by-stage checklist: LEDs → switches → lamp sweep → key
  scan → encryption vs model), measured-vs-expected tables to fill in, Vivado project steps
  (add sources, header include path, XDC), expected resource/timing notes, known limits.
- **Done when:** a person who has never seen the project can follow it.

## Phase 6 — Showcase artifact
- **Goal:** a shareable page for recruiters, admissions committees and friends.
- **Steps:** an interactive Enigma simulator in the browser using the *same* algorithm and test
  vectors as the Verilog; architecture diagram; the verification story (golden model → RTL →
  hardware); the hardware photos; honest status and what is next. Private by default, owner
  decides when to share.
- **Done when:** the artifact is published and the owner has the link.

## Phase 7 — Hardware verification (owner, later)
Run `docs/BRINGUP.md` on the real board with keyboard + lamp board, record results in
`Claude_log.md`, fix anything found **on the dev machine** and repeat.

## Backlog (not in scope yet)
- Morse-code output shown on the original poster/flowchart (needs the transmit side designed).
- Serial/UART link to a PC so messages can be typed and read on screen.
- Rotor/plugboard settings entered from the keyboard (currently presets).
- 4-rotor M4 or Enigma variants with different wirings.
- 7-segment window display (a seven-segment KiCad schematic exists in `schematic/`).
