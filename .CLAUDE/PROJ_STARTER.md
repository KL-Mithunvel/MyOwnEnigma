# PROJ_STARTER.md

These are kl mithunvel's personal preferences and coding standards for AI-assisted development. When starting a new project, copy the relevant sections verbatim into that project's `CLAUDE.md` under `## User Rules`, below the rules copied from `CLAUDE-COMMON.md`. Add project-specific overrides clearly labelled.

---

## Interaction Rules

- **Always open every response with "ok KLM"** followed by a one-line statement of what you are about to do or answer. Examples: "ok KLM, to answer your question —", "ok KLM, let me do this —", "ok KLM, here's what I found —". Never skip this opener, even for short replies.

- **Every git commit must include a co-author trailer** for `kl mithunvel <klm@smtw.in>`. Add the following line at the end of every commit message body (after a blank line):

  ```
  Co-authored-by: kl mithunvel <klm@smtw.in>
  ```

- **Always explain before acting.** Before making any code changes, edits, or file writes, describe exactly what you are going to do and wait for explicit confirmation from the user. List every file that will be changed and what will change in each. Do not proceed until the user says to go ahead.

---

## Software Engineering Preferences

- **DRY (Don't Repeat Yourself):** Extract shared logic into reusable functions. Avoid copy-pasting code blocks.
- **Testing is important:** Write tests for new functionality. Cover the happy path and key failure modes. Use `pytest`; tests live in `tests/`.
- **Consider edge cases:** Think about nulls, empty inputs, boundary values, and concurrent access. Clarify with me if requirements are ambiguous.
- **Explicit over implicit and clever:** Write clear, readable code. Avoid magic numbers, obscure one-liners, and hidden side effects. If someone has to puzzle over what it does, rewrite it.
- **Proper error handling:** Handle errors at the right level. Return meaningful messages. Don't silently swallow exceptions.
- **Deprecation:** Never use deprecated APIs, functions, or modules. If found, rewrite to avoid them after consulting me.

---

## General Principles

- **Simplicity first:** Minimal, straightforward code. No over-engineering.
- **Explain always:** Document your code and decisions. Explain choices and how things work.
- **Backend-heavy:** Prefer logic in the backend; keep frontends thin.

---

## Tech Stack Preferences

| Layer | Choice | Notes |
|-------|--------|-------|
| Languages | Python (latest stable), JavaScript/TypeScript | |
| Backend frameworks | Flask, FastAPI | Flag when FastAPI would be a better fit than Flask |
| Frontend frameworks | Vanilla JS / lightweight frameworks | Keep it simple |
| Python GUI | Tkinter | When a desktop UI is needed |
| Database | SQLite (preferred for local/app data) | Never write to read-only external sources |
| Python packaging | pip + venv | Planned migration to `uv` — flag when recommended |
| Configuration | YAML | For all settings and config files |
| Infrastructure | Windows, Debian/Raspberry Pi OS, Ubuntu LTS | Guard any OS-specific code behind checks |

---

## Commit Message Style

Use imperative mood, short subject line (≤ 72 chars), no trailing period:

```
Add CLAUDE.md for project X
Update TODO list after database integration
Fix Key Conventions section for encoding bug
Add Schema Reference for new data source
```

Do not use vague messages like `update`, `fix stuff`, or `changes`.
