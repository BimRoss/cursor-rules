#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RULE_DIR="$ROOT_DIR/.cursor/rules"

if [[ ! -d "$RULE_DIR" ]]; then
  echo "ERROR: rules directory not found at $RULE_DIR"
  exit 1
fi

failures=0

log_fail() {
  local msg="$1"
  failures=$((failures + 1))
  echo "FAIL: $msg"
}

echo "Running rule audit in $RULE_DIR"

shopt -s nullglob
rule_files=("$RULE_DIR"/*.mdc)
shopt -u nullglob

if [[ ${#rule_files[@]} -eq 0 ]]; then
  log_fail "No .mdc files found."
fi

for file in "${rule_files[@]}"; do
  first_line="$(sed -n '1p' "$file")"
  if [[ "$first_line" != "---" ]]; then
    log_fail "$file missing frontmatter start (--- on line 1)."
  fi

  delim_count="$(awk 'BEGIN{count=0} /^---$/ {count++} END {print count}' "$file")"
  if [[ "$delim_count" -lt 2 ]]; then
    log_fail "$file missing frontmatter closing delimiter."
  fi

  if ! awk 'BEGIN{ok=0} /^description:/ {ok=1} END{exit(ok?0:1)}' "$file"; then
    log_fail "$file missing description field."
  fi
done

for file in "${rule_files[@]}"; do
  base_name="$(basename "$file")"
  if [[ "$base_name" == *" copy.mdc" ]]; then
    log_fail "Detected accidental copy filename: $base_name"
  fi
done

if [[ -n "$(git -C "$ROOT_DIR" ls-files ".cursor/rules/local-context.mdc")" ]]; then
  log_fail ".cursor/rules/local-context.mdc is tracked; it should stay gitignored."
fi

if [[ "$failures" -gt 0 ]]; then
  echo
  echo "Rule audit finished with $failures failure(s)."
  exit 1
fi

echo "Rule audit passed."
