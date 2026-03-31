#!/usr/bin/env bash
# Fail CI if any <employee>-personality.md does not match a fresh render.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIST="${ROOT}/personas/employees.txt"
FAIL=0

check_one() {
  local emp="$1"
  local exclude="${ROOT}/personas/${emp}-slack.exclude"
  local out="${ROOT}/.cursor/personas/${emp}-personality.md"
  local tmp
  tmp="$(mktemp)"
  if [[ ! -f "${out}" ]]; then
    echo "missing ${out}; run: ./scripts/sync-employee-personality.sh --employee ${emp}" >&2
    rm -f "${tmp}"
    return 1
  fi
  if [[ -f "${exclude}" ]]; then
    python3 "${ROOT}/scripts/render-employee-persona.py" \
      --repo-root "${ROOT}" \
      --employee "${emp}" \
      --compact \
      --exclude-file "${exclude}" \
      -o "${tmp}"
  else
    python3 "${ROOT}/scripts/render-employee-persona.py" \
      --repo-root "${ROOT}" \
      --employee "${emp}" \
      --compact \
      -o "${tmp}"
  fi
  if ! cmp -s "${out}" "${tmp}"; then
    echo "FAIL: ${out} is stale." >&2
    echo "Regenerate: ./scripts/sync-employee-personality.sh --employee ${emp}" >&2
    diff -u "${out}" "${tmp}" | head -60 >&2 || true
    rm -f "${tmp}"
    return 1
  fi
  rm -f "${tmp}"
  echo "OK: ${emp}-personality.md matches render."
}

while IFS= read -r line || [[ -n "${line}" ]]; do
  line="${line%%#*}"
  line="$(echo "${line}" | tr -d '[:space:]')"
  [[ -z "${line}" ]] && continue
  if ! check_one "${line}"; then
    FAIL=1
  fi
done < "${LIST}"

exit "${FAIL}"
