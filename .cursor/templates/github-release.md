<!--
  BimRoss standard GitHub Release body (see .cursor/rules/bimross-deploy-tag-and-release.mdc).

  Usage:
  1. Copy this file to a scratch path (e.g. /tmp/release-vX.Y.Z.md).
  2. Remove this comment block; fill sections; delete sections you do not need.
  3. Create the release:
     gh release create "vX.Y.Z" --repo "bimross/REPO" \
       --title "vX.Y.Z — short clause matching Summary" \
       --notes-file /tmp/release-vX.Y.Z.md

  Title line: the --title flag is separate; repeat the version + clause there for the GitHub UI.
-->

## Summary

- What shipped and why it matters (product or ops), 1–3 bullets.

## Changes

### Runtime / app

- Area or package: concise change.

### Config / GitOps

- Manifests, env, or Fleet-facing updates.

### Docs / catalog / other

- Non-code surfaces touched.

## Ops

- **Images:** `geeemoney/…` tags or “unchanged.”
- **Repos / paths:** e.g. `rancher-admin` paths if relevant.
- **Rollout:** CI → registry → GitOps/Fleet async; confirm via usual deploy signals, not this note.

## Verify

- Commands or tests run before the tag (e.g. `go test ./...` for touched packages).
- Do not assert live cluster health from this session.
