# Employee personas (BimRoss / employee-factory)

Persona markdown for Slack and other **employee** runtimes is built by
`scripts/render-employee-persona.py`.

## Convention (no manifest required)

- Put rules in **`.cursor/rules/`** using the employee first name as a **filename prefix**:
  - **Alex (Hormozi):** `alex-*.mdc` — all matching files are concatenated into one `persona.md`.
  - **Future (e.g. Tim):** `tim-*.mdc` for `EMPLOYEE=tim`.
- Files are included in **lexicographic order** by basename (`alex-10x-before-new.mdc` before `alex-core.mdc`). Use consistent prefixes if order matters for a given pair.
- **Optional:** pass `--manifest path/to/list.txt` to pin an explicit ordered list instead of globbing (escape hatch).

`employee-factory` CronJob sets `EMPLOYEE` (e.g. `alex`) and runs the script; you do not maintain `personas/<name>.manifest` unless you choose to.

## Cursor IDE note

If you use **agent-requestable** or pinned rule paths in Cursor settings, update them when renaming files (e.g. `hormozai-trigger.mdc` → `alex-trigger.mdc`).
