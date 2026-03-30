# Cursor Rules

**BimRoss treats the company as code.** This repo is part of that stack: the shared brainstem where we capture how we think, ship, and recover—so intelligence compounds instead of evaporating in chat.

We ingest signal from engineering, product, ops, and the field, then fold it into **rules** (defaults and guardrails) and **skills** (repeatable execution). The same loop updates frontends for humans *and* machines, CI/CD and GitOps habits, collaboration protocols, and the self-healing behaviors we want every agent and human to inherit. Nothing here is decoration; it is wiring.

You do not need our private overlays to get value. The public baseline is meant to be forkable. The private layer exists so operator context stays out of git—by design.

## What You Get

- Cursor rules in `.cursor/rules/` — consistency, safety, and verification under pressure  
- Skills in `.cursor/skills/` — frontend design, MCP servers, transcripts, and more  
- A **public / private** split: reusable baseline on the branch; sensitive context in gitignored overlays  
- Scripts to audit rules and catch drift (`scripts/audit-rules.sh`, `scripts/rules-scorecard.sh`)

## Quick Start

```bash
git clone https://github.com/BimRoss/cursor-rules.git
cd cursor-rules
```

Copy or symlink `.cursor/` into any project, then tailor it to your stack.

## Private Context (Optional)

```bash
cp local-context.mdc.example .cursor/rules/local-context.mdc
```

Keep repos, operator notes, and personal defaults in `local-context.mdc`—it stays local.

## Keep The System Healthy

```bash
./scripts/audit-rules.sh
./scripts/rules-scorecard.sh
```

For history, see `RULES_CHANGELOG.md`.

## Who This Is For

Builders who want **leverage**: predictable AI behavior, fast recovery when something breaks, and standards that survive handoffs—whether you are a solo operator or a team.

## Related BimRoss Projects

- [subnet-signal](https://github.com/BimRoss/subnet-signal)  
- [thread-pilot](https://github.com/BimRoss/thread-pilot)  
- [twitter-scraper](https://github.com/BimRoss/twitter-scraper)  
- [cookie-monster](https://github.com/BimRoss/cookie-monster)

## Keywords

Company as code, Cursor rules, AI agent guardrails, engineering leverage, operator-first automation.

## License

See per-skill `LICENSE.txt` files where present; rules are shared as-is.
