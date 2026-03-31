# Employee personas (BimRoss / employee-factory)

Persona markdown for Slack and other **employee** runtimes is built by
`scripts/render-employee-persona.py`.

## Convention (no manifest required)

- Put rules in **`.cursor/rules/`** using the employee first name as a **filename prefix**:
  - **Alex (Hormozi):** `alex-*.mdc` — all matching files are concatenated into one `persona.md`.
  - **Future (e.g. Tim):** `tim-*.mdc` for `EMPLOYEE=tim`.
- **Kubernetes / Slack (`--compact`):** section titles are short basenames (`## alex-core`), separators are blank lines only (no `---`), **`{employee}-core.mdc` is emitted first**, and **`{employee}-trigger.mdc` / `{employee}-factory.mdc` are skipped** (Cursor orchestration and rule-extraction meta; they duplicate content and bloat the LLM context). Use `--include-meta` if you need them in the bundle.
- **Legacy / full paths:** omit `--compact` to keep `## .cursor/rules/alex-….mdc` headings and `---` between files (debugging or non-LLM consumers).
- **Optional:** pass `--manifest path/to/list.txt` to pin an explicit ordered list instead of globbing (escape hatch). With a manifest, default sort/excludes still apply unless you rely only on manifest order—see script `--help`.

`employee-factory` CronJob sets `EMPLOYEE` (e.g. `alex`) and runs the script with **`--compact`** and **`--stats`** (logs section count + UTF-8 size); you do not maintain `personas/<name>.manifest` unless you choose to.

If present, **`personas/{employee}-slack.exclude`** is passed as **`--exclude-file`**: one rule basename per line, `#` for comments. See [`alex-slack.exclude`](alex-slack.exclude).

## Intelligence vs context (dupes and tuning)

**Not true duplicates (keep):** `alex-core` gives tone, filters, and *pointers* to deep dives (e.g. Ultimate Sales Blueprint). The dedicated files (`alex-ultimate-sales-blueprint`, `alex-sales-closer`, etc.) add detail the model can use on hard questions. Short overlap in core is intentional layering, not wasted tokens.

**Real duplication (already handled):** `{employee}-trigger` (full index of filenames) and `{employee}-factory` (how to author `.mdc` files) are **excluded in `--compact`** because the same rules appear again as full sections.

**Optional trim:** `alex-growth-levers.mdc` is a **map** to other files; those files are already inlined in full. Keeping growth-levers gives the model a **one-screen outline**; dropping it saves a noticeable chunk of tokens. Uncomment the line in [`alex-slack.exclude`](alex-slack.exclude) if you want outline out, map-only savings.

**Going further:** use **`--manifest`** with an explicit ordered list (core + highest-value modules) for very small models or tight `LLM_SYSTEM_MAX_RUNES` caps in employee-factory.

**Verify size:** `python3 scripts/render-employee-persona.py --employee alex --compact --stats -o /tmp/p.md` (stderr shows `sections=` and `bytes_utf8=`).

## Cursor IDE note

If you use **agent-requestable** or pinned rule paths in Cursor settings, update them when renaming files (e.g. `hormozai-trigger.mdc` → `alex-trigger.mdc`).
