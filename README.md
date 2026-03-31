# Cursor Rules

**BimRoss treats the company as code.** This repo is part of that stack: the shared brainstem where we capture how we think, ship, and recover—so intelligence compounds instead of evaporating in chat.  **BimRoss is not a company.** It is a project. It is a way of thinking. It is a way of working. It is a way of living.

## Quick Start

Download this repo and put it in your Cursor workspace.

## Docker image (`geeemoney/cursor-rules`)

GitHub Actions **`.github/workflows/cursor-rules-images.yml`** builds a small Alpine image containing tracked rules and **`.cursor/personas/alex-personality.md`**, pushed to Docker Hub on **`v*`** tags. **employee-factory** runs an initContainer from this image so Kubernetes serves versioned persona text without cloning Git at runtime.

After editing any **`alex-*.mdc`**, run **`./scripts/sync-alex-personality.sh`** and commit the updated **`alex-personality.md`**. CI enforces this with **`scripts/check-alex-personality.sh`**.

**Release order:** publish a **`cursor-rules`** tag (e.g. `v0.0.6`) so the image exists before Fleet rolls manifests that reference **`geeemoney/cursor-rules:0.0.6`**.

**GitHub Actions secrets** (this repo): `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN` (push on `v*`), and `RANCHER_ADMIN_REPO_TOKEN` for **`gitops-release`** (clone/push `bimross/rancher-admin`—same policy as other BimRoss image repos; do not substitute `github.token` for that checkout).