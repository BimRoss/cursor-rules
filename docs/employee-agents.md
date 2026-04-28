# Employee agents (Make A Company / cursor-rules)

This repo is the **shared brain** for first-name **employees** (Alex, Tim, Ross, Garth, ...): Cursor rules (`<name>-*.mdc`), committed **personality bundles**, and (for shipped runtimes) Docker images.

Use **Make A Company** as the product identity in user-facing language. **BimRoss** is the operator LLC and deployment owner context.

## End-to-end flow

1. **Ingest** — Transcribe talks (`transcribe/`, YouTube, etc.). Human reviews raw text.
2. **Extract** — Use `<name>-factory.mdc` to propose atomic `<name>-*.mdc` rules. Keep `<name>-core.mdc` for cross-topic voice; put tactics in small files.
3. **Index** — Update `<name>-trigger.mdc` (and optional `<name>-growth-levers.mdc`) so agents know what exists.
4. **Bundle** — Run `./scripts/sync-employee-personality.sh` (or `--employee tim`). Writes **`.cursor/personas/<name>-personality.md`** from `render-employee-persona.py` (`--compact`, optional `personas/<name>-slack.exclude`). **`bimross-company.mdc`** is prepended into every bundle (shared **Slack/runtime** context: channel-first facts, multi-agent behavior, product/operator naming boundaries); edit it and run **`--all`**.
4b. **Sibling awareness (Slack)** — Add **`.cursor/rules/<name>-sibling-agents.mdc`** and update **every** existing sibling file when the roster grows so each agent knows the others and may @mention them in-thread; see **`bimross-employee-sibling-agents.mdc`**.
5. **Commit** — Rule changes + updated `*-personality.md` in the same change. CI runs `./scripts/check-employee-personality.sh`.
6. **Release** — Tag `cursor-rules` → **`geeemoney/cursor-rules:<semver>`** image contains the repo including all bundles. Kubernetes (e.g. **employee-factory**) uses an initContainer to copy the right `*-personality.md` into the app pod—**no in-cluster Markdown generation**. For a new employee (e.g. **Garth**), bump the init image tag in **`bimross/rancher-admin`** `admin/apps/employee-factory/*-deployment.yaml`, create the matching runtime **`Secret`** (`employee-factory-<name>-runtime`), and set **`GARTH_SLACK_BOT_ID`** (or equivalent) in the shared ConfigMap when the Slack bot exists.

Human-in-the-loop stays at **PR + tag**: nothing ships to production bundles without passing checks.

## Personality update runbook (what updates when)

- **Immediate (local repo):** after editing `*.mdc`, running `./scripts/sync-employee-personality.sh` updates `.cursor/personas/*-personality.md` in your working tree.
- **Commit boundary:** until the regenerated bundles are committed, CI and downstream images still see old personalities.
- **Image boundary:** until a new `cursor-rules` image is built from that commit, runtime initContainers still copy old bundle content.
- **Deploy boundary:** until `employee-factory` rolls to that new image tag, Slack agents keep old personalities in running pods.

Troubleshooting prompt: if behavior did not change in Slack, check this chain in order:
1) rule file changed, 2) sync script run, 3) bundles committed, 4) image published from that commit, 5) deployment updated/rolled.

## Runtime touchpoints (read-only verification anchors)

- Mention/delegation formatting: `employee-factory/internal/slackformat/format.go` (+ tests in `employee-factory/internal/slackformat/format_test.go`)
- Multi-agent slot + bot ID usage: `employee-factory/internal/slackbot/multiagent.go`
- Bot ID env wiring: `rancher-admin/admin/apps/employee-factory/configmap.yaml`
- Squad bot cross-bot delegation gate: `slack-orchestrator/internal/routing/decide.go` and `slack-orchestrator/README.md` ("Squad bot posts and cross-bot delegation")

## Company-specific doctrine (operators)

Customer- or operator-specific roadmap and URLs do **not** live in the prepended bundle by default—ground answers in **the current Slack channel**, tools, and **`local-context.mdc`** / private rules when appropriate. Keep responses phase-accurate: clearly separate **live now** vs **planned later** based on what the thread or product context actually states.

## Naming

- **First name, lowercase** — `alex`, `tim`, `ross`, `garth`, …
- **Rules** — `.cursor/rules/<name>-*.mdc` (glob-stable for tools and Cursor).
- **Bundle** — `.cursor/personas/<name>-personality.md`.
- **New employee checklist** — Add `<name>` to **`personas/employees.txt`**; add **`.cursor/rules/<name>-*.mdc`** globs to **`sync-employee-personality.mdc`** (Cursor trigger); run **`sync-employee-personality.sh --employee <name>`**.
- **Cursor phrase trigger** — for onboarding by prompt (e.g. "lets add an employee"), follow **`.cursor/rules/bimross-add-employee-workflow.mdc`**.

## Where “policy” lives

See **`docs/persona-vs-policy.md`**. Persona text is public and versioned here; authorization, tool allowlists, and audit belong in **application config** (not this repo’s markdown).

## Provenance

Use **`docs/provenance-template.md`** and optional **`personas/SOURCES.md`** to record which transcripts fed which rules.

## Capabilities matrix (living)

See **`docs/agents-capabilities.md`** — maps persona bundles to future/ current runtimes (Slack, Cogito, tools, auth). Update when you wire a new surface.

## Runtime routing contract (all employees)

Slack tool routing should follow a deterministic-first model across all employee agents:

- direct tool intents route deterministically,
- LLM routing is advisory/observability only for direct tool dispatch,
- in threads, tool execution requires explicit specialist mention in the same message,
- routing blockers must return typed deterministic failures (not generic chat fallback).

Canonical policy lives in **`.cursor/rules/slack-deterministic-tool-routing-contract.mdc`**.

## Release operations

For the exact tag -> image -> rancher-admin -> rollout command sequence, use **`docs/cursor-rules-release-checklist.md`**.
