# Employee agents (BimRoss / cursor-rules)

This repo is the **shared brain** for first-name **employees** (Alex, Tim, Ross, Garth, …): Cursor rules (`<name>-*.mdc`), committed **personality bundles**, and (for shipped runtimes) Docker images.

## End-to-end flow

1. **Ingest** — Transcribe talks (`transcribe/`, YouTube, etc.). Human reviews raw text.
2. **Extract** — Use `<name>-factory.mdc` to propose atomic `<name>-*.mdc` rules. Keep `<name>-core.mdc` for cross-topic voice; put tactics in small files.
3. **Index** — Update `<name>-trigger.mdc` (and optional `<name>-growth-levers.mdc`) so agents know what exists.
4. **Bundle** — Run `./scripts/sync-employee-personality.sh` (or `--employee tim`). Writes **`.cursor/personas/<name>-personality.md`** from `render-employee-persona.py` (`--compact`, optional `personas/<name>-slack.exclude`). **`bimross-company.mdc`** is prepended into every bundle (shared company identity); edit it and run **`--all`**.
4b. **Sibling awareness (Slack)** — Add **`.cursor/rules/<name>-sibling-agents.mdc`** and update **every** existing sibling file when the roster grows so each agent knows the others and may @mention them in-thread; see **`bimross-employee-sibling-agents.mdc`**.
5. **Commit** — Rule changes + updated `*-personality.md` in the same change. CI runs `./scripts/check-employee-personality.sh`.
6. **Release** — Tag `cursor-rules` → **`geeemoney/cursor-rules:<semver>`** image contains the repo including all bundles. Kubernetes (e.g. **employee-factory**) uses an initContainer to copy the right `*-personality.md` into the app pod—**no in-cluster Markdown generation**. For a new employee (e.g. **Garth**), bump the init image tag in **`bimross/rancher-admin`** `admin/apps/employee-factory/*-deployment.yaml`, create the matching runtime **`Secret`** (`employee-factory-<name>-runtime`), and set **`GARTH_SLACK_BOT_ID`** (or equivalent) in the shared ConfigMap when the Slack bot exists.

Human-in-the-loop stays at **PR + tag**: nothing ships to production bundles without passing checks.

## Naming

- **First name, lowercase** — `alex`, `tim`, `ross`, `garth`, …
- **Rules** — `.cursor/rules/<name>-*.mdc` (glob-stable for tools and Cursor).
- **Bundle** — `.cursor/personas/<name>-personality.md`.
- **New employee checklist** — Add `<name>` to **`personas/employees.txt`**; add **`.cursor/rules/<name>-*.mdc`** globs to **`sync-employee-personality.mdc`** (Cursor trigger); run **`sync-employee-personality.sh --employee <name>`**.

## Where “policy” lives

See **`docs/persona-vs-policy.md`**. Persona text is public and versioned here; authorization, tool allowlists, and audit belong in **application config** (not this repo’s markdown).

## Provenance

Use **`docs/provenance-template.md`** and optional **`personas/SOURCES.md`** to record which transcripts fed which rules.

## Capabilities matrix (living)

See **`docs/agents-capabilities.md`** — maps persona bundles to future/ current runtimes (Slack, Cogito, tools, auth). Update when you wire a new surface.
