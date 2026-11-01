# CLAUDE.md — MyOwnEnigma

> **IMPORTANT:** Read `CLAUDE-COMMON.md` first (universal workflow rules), then `PROJ_STARTER.md` (owner's
> preferences). This file holds project-specific facts and overrides them where they conflict.
> Companion files in the repo root: `TODO.md`, `Claude_log.md`. Plan: `docs/PLAN.md`.

## Project Overview

An FPGA replica of the German 3-rotor **Enigma I** with plugboard, written in Verilog for the
**Digilent Arty S7-50** (Spartan-7), driving a custom diode-matrix keyboard and a 26-LED lamp board.
Started in 2024 as a Mechatronics course project (VIT Chennai, team of 4; owner: kl mithunvel).
License: see `LICENSE`. Toolchain: Vivado 2024.1 (hardware), Icarus Verilog 12 + Python 3.13 (simulation).

State: the original `test.v` proved keyboard → lamp I/O but was not a real Enigma (see Known Technical
Debt). The rebuild in `rtl/` is verified against a Python golden model in simulation. **Hardware
verification is pending** — the owner has the keyboard + lamp board and will test once the build is done.

## Preflight Gates

1. **Reference model first.** `tools/enigma_ref.py` must pass published Enigma vectors before any Verilog
   is compared to it. *Why:* the original Verilog had no way to prove it was correct.
2. **Sim before silicon.** No change is considered for hardware until `python tools/run_sim.py --all`
   passes. *Why:* CLAUDE-COMMON Deployment Model; no hardware is available during development.

## Running the System

```bash
# one-time
python -m venv venv && source venv/Scripts/activate        # Windows git-bash; venv\Scripts\activate in cmd
pip install -r requirements.txt
winget install Icarus.Verilog                              # then add C:\iverilog\bin to PATH

# every session
source venv/Scripts/activate
export PATH="$PATH:/c/iverilog/bin"
python -m pytest tests -q                                  # reference model (+ RTL tests when present)
python tools/gen_tables.py                                 # regenerate rtl/*.vh from config.yaml
python tools/run_sim.py --all                              # generate vectors, compile, run all testbenches

# hardware (owner, later) — see docs/BRINGUP.md
# Vivado: add rtl/*.v, rtl/*.vh (Verilog Header), constraints/arty_s7_enigma.xdc; top = enigma_top
```

## Architecture

| File | Role | Status |
|------|------|--------|
| `config.yaml` | Single source of every tunable (timing, key matrix, lamp codes, presets, sim) | done |
| `tools/enigma_ref.py` | Golden model (Python) | done |
| `tools/gen_tables.py` | Generates `rtl/enigma_params.vh`, `enigma_tables.vh`, `enigma_presets.vh` | done |
| `tools/gen_vectors.py`, `tools/run_sim.py` | Model-generated vectors; one-command compile + run of all testbenches | done |
| `rtl/enigma_math.vh` | Hand-written mod-26 helpers and the offset rotor pass | done |
| `rtl/plugboard.v` | Pairs → 26-entry swap map, error flag | done |
| `rtl/enigma_core.v` | Stepping + signal path FSM (one stage per clock, 10 clocks/letter) | done |
| `rtl/key_scanner.v` | 4067 column scan, settle, debounce, press/release, rejects 2-key/unknown frames | done |
| `rtl/lamp_driver.v` | Letter → 4067 code, registered outputs, min on-time, hold while key down | done |
| `rtl/sync_debounce.v` | 2-FF synchroniser + debounce for switches/buttons | done |
| `rtl/enigma_top.v` | Arty top: presets, setup mode, window display on the lamps, reload, status LEDs | done |
| `constraints/arty_s7_enigma.xdc` | Pin constraints (all 32 pins cross-checked against the Digilent master XDC) | done |
| `sim/tb_*.v` | Testbenches (directed + model-generated random vectors) | Phases 1–3 |
| `test.v` | Original prototype — **do not edit**, historical record | legacy |

Data flow:

```
 keyboard matrix ──rows──> key_scanner ──key_code/valid──> enigma_core ──lamp_code/done──> lamp_driver ──> lamp board
        ^ col_sel (ck_io0..3)       |                          ^  config: preset (sw[1:0]) / start pos / plug pairs
        └────────────────────────────┘                          └── setup mode (sw[2]): typed letters set start window
```

Concurrency: single 100 MHz clock domain, no CDC besides 2-FF synchronizers on switches, buttons and
keyboard rows. The core takes 11 clocks per letter; the scanner cannot deliver keys that fast.

## Key Conventions

- Letters are 5-bit codes A=0 … Z=25 everywhere in RTL. `5'd31` means "no letter / invalid".
- Left/middle/right order everywhere: `{left, middle, right}` packed MSB→LSB.
- Rotor select code: I=0, II=1, III=2, IV=3, V=4. Reflector select: B=0, C=1.
- Config (rotors, rings, plugs) is read live — change it only between letters.
- Generated files (`rtl/enigma_*.vh`) are never edited by hand; edit `config.yaml` or `enigma_ref.py`.
- Hardware multiplexers are **CD74HC4067** (16-ch). Avoid `sw[3]` as an input (SSTL135, 1.35 V bank).

## Data Files

Committed: sources, docs, KiCad/CAD, `project_1zip.zip` (original Vivado project). Generated and
git-ignored: `sim/build/`. No secrets are used in this project.

## Platform Constraints

Dev: Windows 11, Python 3.13, Icarus Verilog 12. Target: Arty S7-50 at 100 MHz, 3.3 V I/O. RTL is plain
Verilog-2001 style so Vivado 2024.1 and Icarus both accept it.

## Deployment Notes

Dev machine has no board attached. Pre-deploy checklist: `run_sim.py --all` passes; lint clean; XDC
matches `docs/HARDWARE.md`. Hardware smoke test and bring-up steps: `docs/BRINGUP.md`.

## Known Technical Debt

Legacy `test.v` (kept for history, not used by the new design):

1. No rotor stepping — it is a fixed substitution, not Enigma.
2. "Reflector C" pass is a copy of the input (and a one-letter shift in the `sw[1]`/`sw[2]` branches) — not an involution.
3. Forward and return paths are chained as one-way passes; encrypting twice does not decrypt.
4. No ring settings, notches or double-stepping; no plugboard.
5. Mixed blocking/non-blocking assignments, 1-bit×26 arrays, unused `rotor_*` regs — unsafe in simulation.
6. Hardcoded key patterns and clock divisor (violates "no hardcoded parameters").
7. Keyboard sampled against a free-running column counter with no settle time or debounce.
8. Master XDC lists `ck_io4` and `ck_a0` that nothing uses.
9. README said 74HC4051 muxes; the hardware uses CD74HC4067 (fixed).

## Development Rules

1. Verilog must match `enigma_ref.py` on all directed and random vectors (Preflight Gate 1–2).
2. No hardcoded parameters: tunables in `config.yaml` → generated headers or module parameters.
3. Pure logic is kept separate from I/O; each module has its own testbench.
4. Never edit `test.v` or generated headers by hand.
5. Docs, TODO.md and Claude_log.md are updated in the same commit as the change; one commit per phase.

## Project TODO List

Maintained in `TODO.md` (legend: 🔴 bug | 🟡 incomplete | 🟢 not started | ✅ done).

## Interaction note (project override)

Owner asked for autonomous, phase-by-phase execution with a commit per phase for this build. The
"explain before acting" rule from `PROJ_STARTER.md` was satisfied by the approved plan in `docs/PLAN.md`.

## User Rules

Standard User Rules: see `CLAUDE-COMMON.md`. Personal preferences: see `PROJ_STARTER.md`.
