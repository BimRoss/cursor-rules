#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RULE_DIR="$ROOT_DIR/.cursor/rules"

if [[ ! -d "$RULE_DIR" ]]; then
  echo "ERROR: rules directory not found at $RULE_DIR"
  exit 1
fi

shopt -s nullglob
rule_files=("$RULE_DIR"/*.mdc)
shopt -u nullglob

total_rules=${#rule_files[@]}
always_apply_count=0
review_by_count=0

for file in "${rule_files[@]}"; do
  if awk 'BEGIN{ok=0} /^alwaysApply:[[:space:]]*true$/ {ok=1} END{exit(ok?0:1)}' "$file"; then
    always_apply_count=$((always_apply_count + 1))
  fi

  if awk 'BEGIN{ok=0} /^reviewBy:/ {ok=1} END{exit(ok?0:1)}' "$file"; then
    review_by_count=$((review_by_count + 1))
  fi
done

changed_last_30d="$(git -C "$ROOT_DIR" log --since='30 days ago' --name-only --pretty=format: -- .cursor/rules '*.mdc' | awk 'NF' | sort -u | wc -l | tr -d ' ')"

echo "# Rules Scorecard"
echo
echo "- Total rules: $total_rules"
echo "- Always-apply rules: $always_apply_count"
echo "- Rules with reviewBy metadata: $review_by_count"
echo "- Rules changed in last 30 days: $changed_last_30d"
