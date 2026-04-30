---
name: update-issue
description: Update a GitHub issue by number for BimRoss, including title/body changes and project board status updates. Use when the user asks Ross to edit issue metadata, rewrite issue content, or move an issue between Kanban states (for example backlog, in progress, done) in org project 1.
---

# Update issue (Ross)

## Scope

- **Owner:** Ross (technical execution lane).
- **Repo target:** infer from current workspace/repo unless the user specifies a different `owner/repo`.
- **Project board:** BimRoss org project **1** (`https://github.com/orgs/BimRoss/projects/1/views/1`).

## What this skill can change

- Issue **title**.
- Issue **body**.
- Project **Status** field for the issue's project item.

## Required inputs

- Issue number (required).
- Repository (`owner/repo`) if not obvious from current repo.
- Any fields to update:
  - new title (optional),
  - new body (optional),
  - new status label (optional; must match an available project option).

## Update workflow

1. Resolve repository and confirm issue exists.
2. If title/body is requested, edit with `gh issue edit`.
3. If status is requested, discover current project field options dynamically, map the requested label to an option, and set it with `gh project item-edit`.
4. Report what changed (old -> new where possible).

## Commands

```bash
# 1) Verify issue exists
gh issue view <ISSUE_NUMBER> --repo <OWNER/REPO>

# 2) Update title/body as needed (either flag can be omitted)
gh issue edit <ISSUE_NUMBER> \
  --repo <OWNER/REPO> \
  --title "<NEW_TITLE>" \
  --body "<NEW_BODY>"

# 3) Get project metadata (project id + field options)
gh project view 1 --owner BimRoss --format json

# 4) Find the issue's project item id in project 1
gh project item-list 1 --owner BimRoss --format json

# 5) Set project status via field/option ids
gh project item-edit \
  --id <ITEM_ID> \
  --project-id <PROJECT_ID> \
  --field-id <STATUS_FIELD_ID> \
  --single-select-option-id <STATUS_OPTION_ID>
```

## Status option matching

- Do not hardcode status values.
- Read available Status options from `gh project view 1 --owner BimRoss --format json`.
- Match requested status case-insensitively (for example `backlog`, `in progress`, `done`) to the board's actual option names.
- If no exact option exists, return available options and ask the user to pick one.

## Response format

- Include:
  - issue URL,
  - fields changed (title/body/status),
  - final status label if updated.
- If a requested change was skipped, state exactly why (missing permissions, item not on project, invalid status label, etc.).
