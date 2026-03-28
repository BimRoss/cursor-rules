# Cursor Rules

Build faster with Cursor without letting your AI assistant go off the rails.

`cursor-rules` is a production-ready operating system for AI-assisted engineering: clear rules, reusable skills, and workflows that keep output fast, safe, and shippable.

## Why This Repo Exists

Most teams do not have an AI problem. They have a consistency problem.

When your prompts, guardrails, and execution defaults are weak, quality collapses. This repo fixes that with explicit standards for code quality, safety, verification, and repo-specific behavior.

## What You Get

- Battle-tested Cursor rules in `.cursor/rules/`
- Reusable execution skills in `.cursor/skills/`
- Public-safe baseline plus private overlays for sensitive context
- Rule audit scripts to prevent drift over time

## Quick Start

```bash
git clone https://github.com/BimRoss/cursor-rules.git
cd cursor-rules
```

Copy or symlink `.cursor/` into any project, then customize for your stack.

## Set Private Context Early

```bash
cp local-context.mdc.example .cursor/rules/local-context.mdc
```

`local-context.mdc` is gitignored by design. Keep private repos, operator context, and personal preferences there.

## Keep The System Healthy

```bash
./scripts/audit-rules.sh
./scripts/rules-scorecard.sh
```

For historical changes, see `RULES_CHANGELOG.md`.

## Who This Is For

- Cursor power users shipping daily
- Engineering teams that want predictable AI behavior
- Founders and operators who care about speed and correctness

## Related BimRoss Projects

- [subnet-signal](https://github.com/BimRoss/subnet-signal)
- [thread-pilot](https://github.com/BimRoss/thread-pilot)
- [twitter-scraper](https://github.com/BimRoss/twitter-scraper)
- [cookie-monster](https://github.com/BimRoss/cookie-monster)

## Keywords

Cursor rules, AI coding agent guardrails, prompt engineering workflow, developer productivity, AI pair programming standards.

## Support The Project

If this repo makes your team faster, star it so more builders can find it.

## License

See per-skill `LICENSE.txt` files where present; rules are shared as-is.
