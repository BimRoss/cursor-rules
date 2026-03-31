#!/usr/bin/env bash
# Regenerate .cursor/personas/<employee>-personality.md for each employee in personas/employees.txt
# Usage: ./scripts/sync-employee-personality.sh [--all]
#        ./scripts/sync-employee-personality.sh --employee alex
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIST="${ROOT}/personas/employees.txt"
mkdir -p "${ROOT}/.cursor/personas"

sync_one() {
  local emp="$1"
  local exclude="${ROOT}/personas/${emp}-slack.exclude"
  local out="${ROOT}/.cursor/personas/${emp}-personality.md"
  if [[ -f "${exclude}" ]]; then
    python3 "${ROOT}/scripts/render-employee-persona.py" \
      --repo-root "${ROOT}" \
      --employee "${emp}" \
      --compact \
      --stats \
      --exclude-file "${exclude}" \
      -o "${out}"
  else
    python3 "${ROOT}/scripts/render-employee-persona.py" \
      --repo-root "${ROOT}" \
      --employee "${emp}" \
      --compact \
      --stats \
      -o "${out}"
  fi
}

if [[ "${1:-}" == "--employee" && -n "${2:-}" ]]; then
  sync_one "$2"
  exit 0
fi

if [[ "${1:-}" == "--all" ]] || [[ $# -eq 0 ]]; then
  while IFS= read -r line || [[ -n "${line}" ]]; do
    line="${line%%#*}"
    line="$(echo "${line}" | tr -d '[:space:]')"
    [[ -z "${line}" ]] && continue
    sync_one "${line}"
  done < "${LIST}"
  exit 0
fi

echo "usage: $0 [--all] | [--employee <id>]" >&2
exit 1
