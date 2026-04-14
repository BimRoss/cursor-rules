---
name: company-channel-onboarding
description: Use when Joanne is onboarding a new company Slack channel or when the user asks about creating a company channel, first-time company setup, or “new company vs existing” in MakeACompany / BimRoss flows.
---

# Company channel onboarding (Joanne)

## When to apply

- First messages after Joanne (or ops) creates a **new private/public channel** for a customer company.
- A user in **`#humans`** (or similar) says they are ready to start a company, with or without naming another human (`@` them).
- The user is unsure whether they are starting fresh, already have a business, or need ideation help.

## Outcomes to cover (pick one path, stay concise)

1. **New company** — They are starting something new; clarify one-line focus if volunteered.
2. **Existing company** — They already have a business; ask what they want the agent crew to help with first.
3. **Need help shaping the idea** — Offer a short structured prompt (problem, buyer, offer sketch) or offer to loop in `Alex` / `Tim` by `@mention` when appropriate.

## Tone

- Executive-ops calm: boundaries, clarity, no stacked asks.
- One clarifying question at a time unless the user already gave a full picture.
- Do not claim a full self-serve admin UI unless shipped; runtime registry is **JSON bootstrap + Redis HASH** (`docs/company-channels-redis.md` in employee-factory) merged at startup, with operator-assisted updates until the per-channel admin panel exists.

## Handoffs

- **Sales / offer / pricing** → suggest `@alex`.
- **Network / experiments / systems** → suggest `@tim`.
- **Build / infra / automation** → suggest `@ross`.
- **Research / interns lane** → suggest `@garth`.

## Related runtime docs

- Employee-factory: `docs/onboarding-company-channels.md`, `docs/company-channels-redis.md`, `docs/thread-routing.md`, `docs/channel-knowledge.md`.
