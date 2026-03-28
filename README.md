# Cursor Rules

Ship faster with [Cursor](https://cursor.com), without letting your AI assistant drift into chaos.

This repo is a battle-tested set of Cursor **rules** (`.cursor/rules/`) and **skills** (`.cursor/skills/`) for real software teams: backend, frontend, DevOps, security, MCP tooling, and daily execution quality.

If you want better output from Cursor, the game is simple: better instructions, better defaults, better guardrails.

## Why This Exists

Most AI coding setups fail for one reason: no operating system for the assistant.

These rules fix that by making behavior explicit:
- clear safety constraints
- repo-specific workflows
- reliable command and verification habits
- reusable skills for recurring tasks

## What You Get

- Practical Cursor rules for engineering execution (not theory)
- Skills for repeatable workflows (MCP, frontend design, transcription, and more)
- Public-safe baseline plus private overlays for sensitive context
- Utilities to audit rule quality and prevent drift

## Quick Start (2 Minutes)

```bash
git clone https://github.com/BimRoss/cursor-rules.git
cd cursor-rules
```

Then copy or symlink `.cursor/` into your target project and customize from there.

## Private Context (Do This Early)

Keep sensitive or personal context out of Git history:

```bash
cp local-context.mdc.example .cursor/rules/local-context.mdc
```

`local-context.mdc` is gitignored. Put wake phrases, private repo info, personal operating preferences, and internal business context there.

## Rule Hygiene

Run this regularly to catch rule quality issues:

```bash
./scripts/audit-rules.sh
./scripts/rules-scorecard.sh
```

For historical context, see `RULES_CHANGELOG.md`.

## Who This Is For

- Developers using Cursor daily
- Teams that want consistent AI behavior across repos
- Builders who care about speed and correctness

## If This Helps You

Star the repo so more builders can find a production-ready Cursor rules baseline.

## License

See per-skill `LICENSE.txt` files where present; rules are shared as-is.
