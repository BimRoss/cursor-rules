#!/usr/bin/env bash
# Regenerate .cursor/personas/alex-personality.md from .cursor/rules/alex-*.mdc
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p "${ROOT}/.cursor/personas"
exec python3 "${ROOT}/scripts/render-employee-persona.py" \
  --repo-root "${ROOT}" \
  --employee alex \
  --compact \
  --exclude-file "${ROOT}/personas/alex-slack.exclude" \
  --stats \
  -o "${ROOT}/.cursor/personas/alex-personality.md"
