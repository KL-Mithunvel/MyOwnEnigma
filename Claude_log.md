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
