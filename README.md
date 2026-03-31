# Cursor Rules

**BimRoss treats the company as code.** This repo is part of that stack: the shared brainstem where we capture how we think, ship, and recover—so intelligence compounds instead of evaporating in chat. **BimRoss is not a company.** It is a project. It is a way of thinking. It is a way of working. It is a way of living.

## Quick Start

Download this repo and put it in your Cursor workspace.

## Architecture (employees / personas)

- **`docs/employee-agents.md`** — end-to-end flow: transcripts → rules → bundles → image → Kubernetes.
- **`docs/persona-vs-policy.md`** — what stays in markdown vs what belongs in app config (tools, auth).
- **`docs/agents-capabilities.md`** — living matrix: Slack, Cogito, tools, auth (update as you wire surfaces).
- **`docs/provenance-template.md`** + **`personas/SOURCES.md`** — optional source tracking.

Employees (**Alex**, **Tim**, …) are listed in **`personas/employees.txt`**. Each has **`.cursor/rules/<name>-*.mdc`** and a committed **`.cursor/personas/<name>-personality.md`** bundle.

## Docker image (`geeemoney/cursor-rules`)

GitHub Actions **`.github/workflows/cursor-rules-images.yml`** builds an Alpine image containing tracked rules and **all** `*-personality.md` files, pushed to Docker Hub on **`v*`** tags. **employee-factory** (Alex today) uses an initContainer from this image so Kubernetes serves versioned persona text without cloning Git at runtime.

After editing any **`<name>-*.mdc`**, run **`./scripts/sync-employee-personality.sh --employee <name>`** or **`--all`**, and commit the updated **`-personality.md`**(s). CI enforces with **`./scripts/check-employee-personality.sh`**. Wrapper **`./scripts/sync-alex-personality.sh`** only regenerates Alex (back-compat).

**Release order:** publish a **`cursor-rules`** tag so the image exists before Fleet rolls manifests that reference **`geeemoney/cursor-rules:<semver>`**.

**GitHub Actions secrets** (this repo): `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN` (push on `v*`), and `RANCHER_ADMIN_REPO_TOKEN` for **`gitops-release`** (clone/push `bimross/rancher-admin`—same policy as other BimRoss image repos; do not substitute `github.token` for that checkout).
