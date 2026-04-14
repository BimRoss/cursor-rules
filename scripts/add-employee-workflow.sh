#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SLACK_FACTORY_ROOT="${ROOT}/../slack-factory"
MAKEACOMPANY_ROOT="${ROOT}/../makeacompany-ai"

usage() {
  cat <<'EOF'
Usage:
  ./scripts/add-employee-workflow.sh --name <employee> [--display-name <Name>] [--role-title <Title>] [--description <Text>] [--lane <lane>]

Examples:
  ./scripts/add-employee-workflow.sh --name maya --role-title "Head of Product"
  ./scripts/add-employee-workflow.sh --name "sam lee" --display-name "Sam" --lane strategy

Notes:
  - This script updates cursor-rules, slack-factory, and makeacompany-ai.
  - It does not install Slack apps or set runtime secrets; it prints manual follow-ups for employee-factory.
EOF
}

require_dir() {
  local path="$1"
  local label="$2"
  if [[ ! -d "$path" ]]; then
    echo "Missing ${label} directory: $path" >&2
    exit 1
  fi
}

to_slug() {
  local raw="$1"
  python3 - "$raw" <<'PY'
import re
import sys
raw = sys.argv[1]
slug = re.sub(r'[^a-z0-9]+', '-', raw.strip().lower()).strip('-')
print(slug)
PY
}

to_display_name() {
  local slug="$1"
  python3 - "$slug" <<'PY'
import sys
slug = sys.argv[1].strip().replace('-', ' ')
parts = [p for p in slug.split() if p]
print(" ".join(p[:1].upper() + p[1:] for p in parts))
PY
}

employee_name=""
display_name=""
role_title=""
description=""
lane="general"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name)
      employee_name="${2:-}"
      shift 2
      ;;
    --display-name)
      display_name="${2:-}"
      shift 2
      ;;
    --role-title)
      role_title="${2:-}"
      shift 2
      ;;
    --description)
      description="${2:-}"
      shift 2
      ;;
    --lane)
      lane="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$employee_name" ]]; then
  echo "--name is required" >&2
  usage
  exit 1
fi

slug="$(to_slug "$employee_name")"
if [[ -z "$slug" ]]; then
  echo "Unable to derive employee slug from: $employee_name" >&2
  exit 1
fi

if [[ -z "$display_name" ]]; then
  display_name="$(to_display_name "$slug")"
fi
if [[ -z "$role_title" ]]; then
  role_title="AI Employee"
fi
if [[ -z "$description" ]]; then
  description="${role_title} focused on ${lane} outcomes."
fi

require_dir "$ROOT" "cursor-rules"
require_dir "$SLACK_FACTORY_ROOT" "slack-factory"
require_dir "$MAKEACOMPANY_ROOT" "makeacompany-ai"

echo "Scaffolding employee:"
echo "  slug: $slug"
echo "  display: $display_name"
echo "  role: $role_title"
echo "  lane: $lane"

EMP_LIST="${ROOT}/personas/employees.txt"
if ! rg -n "^${slug}$" "$EMP_LIST" >/dev/null 2>&1; then
  printf '%s\n' "$slug" >> "$EMP_LIST"
  echo "Added ${slug} to personas/employees.txt"
else
  echo "Employee ${slug} already listed in personas/employees.txt"
fi

TRIGGER_RULE="${ROOT}/.cursor/rules/${slug}-trigger.mdc"
if [[ ! -f "$TRIGGER_RULE" ]]; then
  cat > "$TRIGGER_RULE" <<EOF
---
description: Apply when user says "hi ${slug}", "hey ${slug}", "${slug}", or asks for ${display_name} explicitly.
alwaysApply: false
reviewBy: "2026-09-30"
---
# ${display_name} trigger

Apply this persona when Grant directly calls for ${display_name} by name.
EOF
  echo "Created ${TRIGGER_RULE}"
fi

CORE_RULE="${ROOT}/.cursor/rules/${slug}-core.mdc"
if [[ ! -f "$CORE_RULE" ]]; then
  cat > "$CORE_RULE" <<EOF
---
description: Core behavior for ${display_name} persona.
alwaysApply: false
reviewBy: "2026-09-30"
---
# ${display_name} core

You are ${display_name}. Role: ${role_title}. Lane: ${lane}.

## Operating defaults

- Keep responses concise, practical, and execution-focused.
- Prefer concrete next steps with validation criteria.
- Escalate to Ross for deep infra/deploy execution when needed.
EOF
  echo "Created ${CORE_RULE}"
fi

"${ROOT}/scripts/sync-employee-personality.sh" --employee "$slug"
echo "Synced personality bundle for ${slug}"

NEW_MANIFEST="${SLACK_FACTORY_ROOT}/manifests/${slug}/app-manifest.json"
mkdir -p "${SLACK_FACTORY_ROOT}/manifests/${slug}"
if [[ ! -f "$NEW_MANIFEST" ]]; then
  python3 - "${SLACK_FACTORY_ROOT}/manifests/alex/app-manifest.json" "$NEW_MANIFEST" "$display_name" "$description" <<'PY'
import json
import sys
src, dst, display_name, short_desc = sys.argv[1:]
with open(src, encoding="utf-8") as f:
    doc = json.load(f)
doc.setdefault("display_information", {})
doc["display_information"]["name"] = display_name
doc["display_information"]["description"] = short_desc
doc["display_information"]["long_description"] = short_desc
doc.setdefault("features", {}).setdefault("bot_user", {})
doc["features"]["bot_user"]["display_name"] = display_name
with open(dst, "w", encoding="utf-8") as f:
    json.dump(doc, f, indent=2)
    f.write("\n")
PY
  echo "Created ${NEW_MANIFEST}"
else
  echo "Manifest already exists for ${slug}: ${NEW_MANIFEST}"
fi

python3 - "${SLACK_FACTORY_ROOT}/skills-catalog.json" "$slug" "$display_name" "$description" <<'PY'
import json
import sys
path, slug, label, desc = sys.argv[1:]
with open(path, encoding="utf-8") as f:
    doc = json.load(f)
core = doc.setdefault("coreEmployees", [])
if not any(str(item.get("id", "")).strip().lower() == slug for item in core):
    core.append({"id": slug, "label": label, "description": desc})
doc.setdefault("employeeSkillIds", {})
doc["employeeSkillIds"].setdefault(slug, [])
with open(path, "w", encoding="utf-8") as f:
    json.dump(doc, f, indent=2)
    f.write("\n")
PY
echo "Updated slack-factory skills catalog for ${slug}"

"${SLACK_FACTORY_ROOT}/scripts/validate-manifests.sh"
echo "Validated slack-factory manifests"

(cd "$MAKEACOMPANY_ROOT" && npm run sync:team)
echo "Synced makeacompany-ai snapshots"

cat <<EOF

Manual follow-ups (employee-factory / Slack install):
  1) Create/install Slack app for ${display_name} and capture:
     - ${slug^^}_SLACK_APP_TOKEN
     - ${slug^^}_SLACK_BOT_TOKEN
     - ${slug^^}_SLACK_USER_TOKEN
     - ${slug^^}_SLACK_BOT_ID
  2) Add runtime mappings in employee-factory config/gitops if this employee should join multiagent order.
  3) Update employee-specific tool/env validation in employee-factory when adding new runtime capabilities.

Scaffold complete for: ${slug}
EOF
