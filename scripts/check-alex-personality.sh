#!/usr/bin/env bash
# Fail CI if alex-personality.md does not match a fresh render from alex-*.mdc rules.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="${ROOT}/.cursor/personas/alex-personality.md"
TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

python3 "${ROOT}/scripts/render-employee-persona.py" \
  --repo-root "${ROOT}" \
  --employee alex \
  --compact \
  --exclude-file "${ROOT}/personas/alex-slack.exclude" \
  -o "${TMP}"

if [[ ! -f "${OUT}" ]]; then
  echo "missing ${OUT}; generate with scripts/sync-alex-personality.sh" >&2
  exit 1
fi

if ! cmp -s "${OUT}" "${TMP}"; then
  echo "FAIL: .cursor/personas/alex-personality.md is stale (differs from render)." >&2
  echo "Regenerate: ./scripts/sync-alex-personality.sh" >&2
  diff -u "${OUT}" "${TMP}" | head -80 >&2 || true
  exit 1
fi

echo "alex-personality.md matches render-employee-persona.py output."
