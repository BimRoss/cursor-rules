#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RULE_DIR="$ROOT_DIR/.cursor/rules"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

if [[ ! -d "$RULE_DIR" ]]; then
  echo "ERROR: rules directory not found at $RULE_DIR"
  exit 1
fi

failures=0
warnings=0

log_fail() {
  local msg="$1"
  failures=$((failures + 1))
  echo "FAIL: $msg"
}

log_warn() {
  local msg="$1"
  warnings=$((warnings + 1))
  echo "WARN: $msg"
}

echo "Running rule audit in $RULE_DIR"

shopt -s nullglob
rule_files=("$RULE_DIR"/*.mdc)
shopt -u nullglob

if [[ ${#rule_files[@]} -eq 0 ]]; then
  log_fail "No .mdc files found."
fi

descriptions_file="$TMP_DIR/descriptions.txt"
titles_file="$TMP_DIR/titles.txt"

for file in "${rule_files[@]}"; do
  base_name="$(basename "$file")"
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
  else
    description="$(awk -F'description:' '/^description:/{sub(/^[[:space:]]+/, "", $2); gsub(/^"|"$/, "", $2); print $2; exit}' "$file")"
    if [[ -n "$description" ]]; then
      printf '%s\t%s\n' "$description" "$base_name" >> "$descriptions_file"
    fi
  fi

  always_apply="$(awk -F'alwaysApply:' '/^alwaysApply:/{sub(/^[[:space:]]+/, "", $2); print tolower($2); exit}' "$file")"
  review_by="$(awk -F'reviewBy:' '/^reviewBy:/{sub(/^[[:space:]]+/, "", $2); gsub(/^"|"$/, "", $2); print $2; exit}' "$file")"
  if [[ -n "$review_by" ]]; then
    if [[ ! "$review_by" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
      log_fail "$base_name has invalid reviewBy format ($review_by). Use YYYY-MM-DD."
    fi
  elif [[ "$always_apply" == "true" && "$base_name" != "rules-lifecycle-reviewby.mdc" && "$base_name" != "local-context.mdc" ]]; then
    log_warn "$base_name is alwaysApply but has no reviewBy metadata."
  fi

  if [[ "$base_name" == *" copy.mdc" ]]; then
    log_fail "Detected accidental copy filename: $base_name"
  fi

  title_line="$(awk 'found==1 && NF {print $0; exit} /^---$/ {found++; next}' "$file")"
  if [[ "$title_line" =~ ^# ]]; then
    normalized_title="$(printf '%s' "$title_line" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/ /g; s/[[:space:]]\+/ /g; s/^ //; s/ $//')"
    printf '%s\t%s\n' "$normalized_title" "$base_name" >> "$titles_file"
  fi
done

if [[ -n "$(git -C "$ROOT_DIR" ls-files ".cursor/rules/local-context.mdc")" ]]; then
  log_fail ".cursor/rules/local-context.mdc is tracked; it should stay gitignored."
fi

if [[ -f "$descriptions_file" ]]; then
  duplicates="$(awk -F'\t' '{count[$1]++; files[$1]=files[$1] ", " $2} END {for (d in count) if (count[d] > 1) printf "%s =>%s\n", d, files[d]}' "$descriptions_file")"
  if [[ -n "$duplicates" ]]; then
    while IFS= read -r line; do
      log_fail "Duplicate description detected: $line"
    done <<< "$duplicates"
  fi
fi

if [[ -f "$titles_file" ]]; then
  dup_titles="$(awk -F'\t' '{count[$1]++; files[$1]=files[$1] ", " $2} END {for (t in count) if (count[t] > 1) printf "%s =>%s\n", t, files[t]}' "$titles_file")"
  if [[ -n "$dup_titles" ]]; then
    while IFS= read -r line; do
      log_warn "Potential overlapping rule titles: $line"
    done <<< "$dup_titles"
  fi
fi

if [[ "$failures" -gt 0 ]]; then
  echo
  echo "Rule audit finished with $failures failure(s) and $warnings warning(s)."
  exit 1
fi

echo "Rule audit passed with $warnings warning(s)."
