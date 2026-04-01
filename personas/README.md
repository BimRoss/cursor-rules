# Employee personas (BimRoss)

Persona markdown for Slack and other **employee** runtimes is built by **`scripts/render-employee-persona.py`**, orchestrated by **`scripts/sync-employee-personality.sh`**.

## Employees list

**`employees.txt`** — one lowercase first name per line (`alex`, `tim`, `ross`, `garth`, …). Used by **`sync-employee-personality.sh`** / **`check-employee-personality.sh`** to regenerate or verify **every** **`.cursor/personas/<name>-personality.md`**.

## Committed bundles

For each employee, production (when wired) uses **`.cursor/personas/<name>-personality.md`**: same render as local (`--compact`, optional **`personas/<name>-slack.exclude`**).

- Regenerate: **`./scripts/sync-employee-personality.sh --all`** or **`--employee tim`**.
- CI: **`./scripts/check-employee-personality.sh`**
- Cursor rule: **`sync-employee-personality.mdc`**
- Kubernetes (Alex): bundle inside **`geeemoney/cursor-rules`** image — see **`docs/employee-agents.md`**.

## Convention (no manifest required)

- Rules live in **`.cursor/rules/`** with first-name prefix: **`alex-*.mdc`**, **`tim-*.mdc`**, …
- **`--compact`** (Slack / LLM): short headings (`## tim-core`), blank-line separators, **`{name}-core.mdc` first**, **`{name}-trigger`** and **`{name}-factory`** skipped unless you use `--include-meta`.
- Optional **`personas/{name}-slack.exclude`**: one basename per line to drop index files from the Slack bundle (e.g. **`tim-growth-levers.mdc`**, **`alex-growth-levers.mdc`**) to save tokens.

## Intelligence vs context (dupes and tuning)

**Not duplicates (keep):** `{name}-core` gives voice + pointers; atomic files add depth on hard questions.

**Already excluded in `--compact`:** `{name}-trigger` and `{name}-factory` — Cursor orchestration, not the Slack system prompt.

**Optional trim:** growth-levers files are maps; exclude via **`*-slack.exclude`** if the full inlines are enough.

**Verify size:**  
`python3 scripts/render-employee-persona.py --employee tim --compact --stats -o /tmp/t.md`

## Cursor IDE note

If you rename rule files, update **agent-requestable** paths and **`sync-employee-personality.mdc`** globs when adding a **new** employee name.
