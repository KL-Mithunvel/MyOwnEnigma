# CLAUDE-COMMON.md

This file contains universal process and workflow rules that apply to **every project** using this library.

When starting a new project:
1. Copy the **Standard User Rules** section verbatim into that project's `CLAUDE.md` under `## User Rules`.
2. Also copy the relevant sections from `PROJ_STARTER.md` (personal preferences) below those rules.
3. Add project-specific overrides clearly labelled at the bottom.

---

## Standard User Rules

### Companion Files

Claude must maintain two files in every project root alongside `CLAUDE.md`. Create them on the first session if they do not exist.

#### `TODO.md` — Task Tracker

Tracks what has been done and what still needs doing. Update it whenever a task is started, completed, or discovered.

```markdown
# TODO

## In Progress
- [ ] <task>

## Done
- [x] <task> — <brief note on outcome>

## Not Started
- [ ] <task>
```

Rules:

- Move items from **Not Started → In Progress → Done** as work progresses. Never delete entries; they are the audit trail.
- Add newly discovered tasks immediately — do not hold them until the end of a session.
- Link to the relevant commit hash next to Done items where possible.

#### `Claude_log.md` — Session Log

Records what was actually done, session by session. Append a new entry at the start of every session and fill it in as work proceeds.

```markdown
# Claude Log

## YYYY-MM-DD — <one-line session summary>
- <action taken and outcome>
- <files changed and why>
- <decisions made and rationale>
- <anything left incomplete and why>
```

Rules:

- One dated entry per session. Multiple entries on the same date are allowed if there are distinct work blocks.
- Keep entries factual and concise — not a stream of consciousness. Focus on *what changed* and *why*.
- Both files must be committed alongside any code changes they describe. Never let them drift out of sync.

---

### Documentation Discipline

These rules apply to every session. Documentation is not optional — it is part of completing a task.

#### What must be documented

- **Finalized decisions:** Whenever something is discussed and agreed upon (approach, architecture, tool choice, naming convention, etc.), record it immediately in the relevant file. A decision not written down does not exist.
- **Incidental information:** If useful facts, constraints, or context surface during a prompt (e.g. a hardware pin-out, an API limit, a naming rule), document them in the same session — do not defer to a follow-up.
- **Multi-phase plans:** Any plan with two or more phases must be written down in full before execution begins. Each phase should list: goal, steps, files affected, and success criteria.

#### Where to store things

- **Prefer existing files.** Before creating a new file, check whether the information belongs in `CLAUDE.md`, `CLAUDE-COMMON.md`, `PROJ_STARTER.md`, `TODO.md`, or `Claude_log.md`. Only create a new file if the content genuinely does not fit anywhere existing.
- **If no suitable file exists**, create a `docs/` folder in the repo root and store the document there. Do not scatter files across the repo.
- **One file per concern.** Do not create multiple small files for related topics — consolidate into one document unless the content is clearly distinct.

#### Priority rule

Maintaining accurate documentation takes priority over speed. If a task is complete but the docs are not updated, the task is not done. Update docs in the same commit as the code change — never as a follow-up.

---

### Secrets & Credentials

- **Keys, tokens, and passwords live only in a gitignored `.env` file** (or the OS secret store). Never in source code, `config.yaml`, commits, logs, or chat. Never ask the user to paste a secret into the conversation.
- **Commit a `.env.example`** that lists every variable name with a placeholder value, so a new machine knows what to set.
- **Read secrets from the environment** (`os.environ`, or `python-dotenv` to load `.env`). When one is missing, fail with a message that names the variable — never print its value.
- **Projects that use an external service should ship a small setup-check script** that confirms the variables are present (and, where cheap, makes one live call) so a new machine can be verified in one command.
- **If a secret is ever committed, treat it as compromised.** Rotate it. Removing it from git history is not enough.

---

### Preflight Gates

Some projects have steps that must be completed — with the outcome written down — before any code is written or changed. These are *gates*.

Rules:

- **Each project defines its own gates** in its `CLAUDE.md` under `## Preflight Gates`, in the order they apply. Delete the section if the project has none.
- **Claude must not write or modify the code a gate covers until that gate is cleared** and its outcome recorded in `Claude_log.md` (and in `docs/` if it is a durable decision).
- **Every gate carries a one-line "why this exists"** — the cost that was paid without it. A gate with no evidence behind it is only a suggestion.
- **Re-run a gate when its inputs change** — a new data source, a new machine, a new deployment target.

Generic example gates. Adopt, adapt, or replace them:

1. **Understand the existing state before changing anything.** Before touching anything that reads or transforms existing data (a database, an API, a dataset, a legacy codebase), build a factual picture of what actually exists and write it down:
   - **Inventory:** what is there, where it lives, how much, in what format.
   - **Provenance:** where it came from and how far it can be trusted. Every result built on it inherits that caveat.
   - **Coverage gaps:** what it does *not* contain. State this explicitly so results never imply more than the data supports.
   - **Environment dependence:** which values only hold for this scale, device, or setup and will not transfer.
   - **Read-only sources stay read-only.**
2. **Survey the environment before development.** Run `tools/compute_survey.py` (CPU, RAM, disk, GPU) and record the output. Then check that the code will actually use what is there (e.g. a GPU that a default CPU-only install silently ignores) and does not assume anything that is not.
3. **Confirm where it will run, first.** Before choosing a platform, framework, or architecture, answer and record:
   - Where does it run in the end — cloud, on-prem server, laptop, single-board computer, microcontroller? Online or offline?
   - What are the target's limits — latency, CPU/GPU, memory, storage?
   - Which artifacts must be exportable, and does the chosen platform let them leave? (A hosted tool that only exposes an API is a dead end for an offline target.)
   - What is the fallback if the first candidate is too heavy for the target?

---

### Deployment Model

**The hard rule: write and test on the development machine first. Hardware comes last.**

This applies to every project that has a hardware target (Raspberry Pi, Arduino, embedded Linux, remote server). It is not optional.

#### Stages — always in this order

1. **Code on dev machine** — write all logic, module interfaces, and data flows on the laptop/desktop. The dev machine is Windows or Linux; it has no GPIO, no I2C, no serial ports.
2. **Test on dev machine** — run the full test suite (`pytest`). Verify the feature works end-to-end using the simulation/dev stack (fake sensors, mock hardware, local SQLite). Fix all failures before moving on.
3. **Review for hardware impact** — before touching the device, explicitly state which parts of the change touch real hardware (GPIO pins, I2C addresses, serial ports, baud rates) and which parts are pure logic.
4. **Deploy to hardware** — only after steps 1–3 are complete. Transfer code via `git pull`, `rsync`, `scp`, or `arduino-cli` as appropriate for the project. Run the hardware smoke test.
5. **Verify on hardware** — run the hardware-specific test or verification script. Note any behaviour difference from simulation. If there is a discrepancy, fix it on the dev machine (step 1) and repeat — never patch directly on the device.

#### Rules that follow from this

- **Every hardware driver must have a simulated equivalent** that runs on the dev machine and produces the same data shape and exceptions. Code written without a simulation path cannot be tested in stage 2 and breaks the workflow.
- **Never hardcode hardware addresses, port names, or pin numbers in driver files.** They go in `config.yaml` and are passed as parameters. This lets the same code run in simulation (with dev values) and on hardware (with real values).
- **When proposing a change**, always separate it into: (a) logic that can be fully verified on the dev machine, and (b) hardware-specific parts that need device testing. State both explicitly so the user knows what to test where.
- **Never instruct the user to "just run it on the device"** as a substitute for a dev-machine test. If a test cannot be run on the dev machine due to a hardware dependency, say so clearly and explain what the device test will verify.

---

### Commands & Workflow

- **Always activate the project virtualenv before running any Python command.** Use `source venv/bin/activate` (Linux/macOS) or `venv\Scripts\activate` (Windows). Never invoke `python` or `pip` bare without the venv active.
- **No hardcoded parameters.** Thresholds, paths, device indices, ports, hyperparameters, URLs, and every other tunable live in a `config.yaml` and are passed in as parameters — never inline in code. This applies to every project, not only those with hardware.
- Track all dependencies in `requirements.txt`. Pin at least the major version. Run `pip freeze > requirements.txt` after installing anything new.
- A migration to `uv` is planned. Flag `uv` as a recommended replacement whenever suggesting new tooling or packaging steps.
- Run lints (`python -m py_compile` at minimum, `flake8` or `ruff` if configured) and the test suite before every commit.

---

## Standard Template Structure

Every `CLAUDE.md` derived from this library follows this skeleton. **Sections marked `[if applicable]` are included when relevant and omitted otherwise.** Fill each section completely or delete it — a half-filled section is worse than a missing one.

```
# CLAUDE.md

## Project Overview
  — What the project is, who built it, the core problem it solves.
  — Author, license, entry point, minimum runtime versions.

## Preflight Gates  [if applicable — projects with steps that must be cleared before coding]
  — Numbered gates in the order they apply, each with a one-line "why this exists".
  — What must be recorded to clear each gate, and where (Claude_log.md, docs/).
  — See "Preflight Gates" under Standard User Rules for the rules and example gates.

## Running the System
  — Copy-paste-ready commands to start, test, and lint.
  — Virtualenv activation step first.
  — Dev/simulation mode commands separated from hardware/production commands.
  — Any seed-data or one-time setup steps.

## Architecture
  — Module responsibilities table (file → role).
  — Data flow diagram (ASCII).
  — Threading or async model (background threads, queues, event loops).
  — Two modes if applicable: simulation/dev vs real/hardware, and how to switch.

## Key Modules
  — One subsection per file or logical group.
  — Public interface: function names, parameters, return types, exceptions raised.
  — Side effects and I/O (files written, network calls, hardware access).

## Schema Reference  [if applicable — any project with a DB or external data source]
  — Path to the DDL / schema file and what it covers (table count, source DB engine).
  — Read-only vs writable databases — call out explicitly which is which.
  — Any tooling for probing or inspecting the DB (probe scripts, GUIs, CLI commands).
  — Path to the annotated schema doc (SCHEMA.md or equivalent) if one exists.
  — Standing instruction: update the annotated doc whenever a new table relationship
    or encoding is discovered — do it in the same commit, not as a follow-up.

## Key Conventions  [if applicable — any non-obvious encoding, key, or domain rule]
  — Universal row keys (name, type, which tables carry it).
  — Encoded fields: encoding formula AND decode formula, both written out in full.
    Never leave the decode implicit — Claude will guess wrong without it.
  — Sentinel / special values: what NULL means, what -1 means, what empty string means.
  — "Current record" pattern: which column and which value indicate the active row.
  — Per-tenant / per-instance data partitioning: directory layout, naming convention,
    and the helper function that resolves the path.
  — Environment variables: name, what it overrides, and the hard-coded default.

## Data Files
  — What is stored, where, and whether it is git-tracked.
  — Runtime-generated files (logs, caches, DBs) vs committed files.
  — Files that must never be committed (credentials, large binaries).

## Platform Constraints
  — Target OS(es) and any OS-specific branching in the code.
  — Libraries that are platform-specific and how each is guarded (try/except ImportError).
  — Hardware dependencies (I2C, UART, GPIO, RS485) and their dev-mode equivalents.

## Deployment Notes  [if applicable — projects with a hardware or remote server target]
  — Two-environment table: dev machine (OS, Python version, what hardware is absent)
    vs deployment target (OS, Python version, what hardware is present).
  — How to transfer code: exact command (git pull / rsync / scp / arduino-cli upload).
  — One-time setup steps on the target that are NOT in requirements.txt
    (apt packages, system services, udev rules, etc.).
  — Pre-deploy checklist: what must pass on the dev machine before touching hardware.
  — Hardware smoke-test: the exact command to run on the device to confirm it works.
  — Config / env differences between dev and deployment
    (port names, GPIO chip paths, I2C addresses, env vars that change).

## Known Technical Debt
  — Existing rule violations, numbered by the rule they violate (file + line if known).
  — Temporary workarounds that must be cleaned up before the next milestone.
  — Do not omit or minimise debt — document it so it is not accidentally perpetuated.

## Development Rules
  — Binding architectural rules, each numbered and sourced (wiki page, agreed spec, etc.).
  — Rules are referenced by number in TODO items and commit messages.

## Project TODO List
  Legend: 🔴 Bug / rule violation  |  🟡 Incomplete feature  |  🟢 Not started  |  ✅ Done
  Group by severity: CRITICAL → HIGH → MEDIUM → LOW → NOT STARTED → DONE.

## User Rules
  — Copy Standard User Rules from CLAUDE-COMMON.md verbatim here.
  — Copy personal preferences from PROJ_STARTER.md below those.
  — Add project-specific overrides or additions at the bottom, clearly labelled.
```

---

## Standard Project Layout

The default shape of a project repo. Adapt the names, keep the separations.

```
<project>/
├── CLAUDE.md, TODO.md, Claude_log.md   # rules + companion files
├── .gitignore                          # venv, .env, data/, caches, IDE files
├── .env.example                        # variable names only, placeholder values
├── requirements.txt                    # pinned deps
├── config.yaml                         # every tunable (or one per module)
├── <package>/                          # source: pure logic + thin I/O wrappers
├── tools/                              # dev-only helper scripts (e.g. compute_survey.py)
├── tests/                              # pytest
├── docs/                               # non-code artifacts, filed in the same commit
└── data/                               # gitignored — never committed
```

Rules that follow from it:

- **Pure logic is kept separate from I/O** (hardware, network, files). Pure logic gets `pytest` coverage; I/O wrappers get smoke tests.
- **`data/` is never committed.** Small derived records (manifests, metrics) may be.
- **New non-code artifacts go in `docs/`** in the same commit that produced them.

---

## Example: Schema Reference & Key Conventions

> **This is a generic example. Replace every value with your project's actual data.**

### Schema Reference

- `schema/schema.sql` — Full DDL exported from the source database
- `schema/SCHEMA.md` — Annotated interpretation: table purposes, join paths, quirks
- **The source schema is read-only — never attempt to modify it.**
- Use `tooling/probe.py <TABLE_NAME>` to fetch sample records from any table.
- Update `schema/SCHEMA.md` in the same commit whenever a new table relationship or field encoding is discovered. Do not leave it as a follow-up.

### Key Conventions

- **`ENTITY_ID`** — universal primary key across all tables; always an integer; never null.
- **`PERIOD`** — integer encoded as `YEAR * 12 + MONTH` (not YYYYMM, not a date).
  - Encode: `P = year * 12 + month`
  - Decode: `month = P % 12 or 12`, `year = P // 12 - (1 if month == 12 else 0)`
  - Example: April 2024 → `2024 * 12 + 4 = 24292`
- **`ENTITY_MASTER`** — `END_DATE IS NULL` means current/active record. Always filter with `WHERE END_DATE IS NULL` when you want the current state.
- **Per-instance data** is stored under `backend/data/<INSTANCE_ID>/`. Always resolve this path via the `_data_dir(instance_id)` helper — never construct the path by hand.
- **`APP_DATA_ROOT`** env var overrides the data root directory. Default: `backend/data/`.

### What makes these sections effective

| Property | Why it matters |
|----------|----------------|
| Decode formula written out in full | Claude will derive the wrong formula from the field name alone |
| A worked numeric example for encoded fields | Confirms the formula is correct; catches off-by-one errors in the doc itself |
| "Current record" sentinel named explicitly | Without this, Claude queries all history rows and gets inflated results |
| PK type stated (text vs integer) | Prevents type-mismatch bugs in generated SQL and ORM queries |
| Path helper named | Prevents hand-rolled path strings scattered across the codebase |
| Env var default value stated | Lets Claude reason about behaviour without needing to read the source |

---

## Example: Deployment Notes

> **This is a generic example. Replace every value with your project's actual data.**

### Environments

| | Dev machine | Deployment target |
|--|-------------|-------------------|
| OS | Windows 11 / Ubuntu 22.04 | Raspberry Pi OS (Debian Bookworm, 64-bit) |
| Python | 3.12 (venv) | 3.11 (system) |
| Hardware | None — simulated via `hw/sim.py` | Actual sensors / actuators |
| Entry point | `python main_sim.py` | `python main.py` |
| Service URL | `http://127.0.0.1:5000` | `http://<device-ip>:5000` |

### Transferring Code

```bash
# On the target device — pull latest
git pull origin main

# From dev machine — push files directly
rsync -avz --exclude '.git' --exclude 'data/' ./ user@<device-ip>:~/project/
```

### One-Time Setup on Target (not in `requirements.txt`)

```bash
sudo apt install python3-smbus python3-libgpiod
python3 -m venv --system-site-packages venv
source venv/bin/activate
pip install -r requirements.txt
```

### Pre-Deploy Checklist (must pass on dev machine first)

- [ ] `pytest tests/` passes with zero failures
- [ ] `python main_sim.py` starts and the UI/dashboard loads correctly
- [ ] Data files are being written each poll cycle
- [ ] No unfinished `TODO` stubs in any function called during the run

### Hardware Smoke Test (run on device after deploy)

```bash
# Test each hardware interface individually
python hw/sensor_a.py    # should print live readings
python hw/sensor_b.py    # should print live readings

# Run the full system
python main.py
```

### Config / Env Differences Between Dev and Target

| Setting | Dev value | Target value | Where set |
|---------|-----------|--------------|-----------|
| Hardware port | N/A | `/dev/ttyACM0` | `config.yaml` |
| GPIO chip | N/A | `/dev/gpiochip0` | `config.yaml` |
| `USE_REAL_HARDWARE` flag | `False` | `True` | Top of `main.py` — edit before deploy |

---

## Quick Reference

```bash
# List all project briefs in this repo
ls *.md

# Copy a brief into a new project
cp <project-id>.md ~/projects/new-project/.CLAUDE.md

# Always activate the venv first (every session, every project)
source venv/bin/activate    # Linux / macOS / Raspberry Pi
venv\Scripts\activate       # Windows
```
