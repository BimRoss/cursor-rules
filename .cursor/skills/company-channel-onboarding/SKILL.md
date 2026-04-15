---
name: company-channel-onboarding
description: Use when Joanne is onboarding a new company Slack channel or when the user asks about creating a company channel, first-time company setup, or “new company vs existing” in MakeACompany / BimRoss flows.
---

# Company channel onboarding (Joanne)

## Runtime (shipped)

- **Create channel** (`write-slack`): confirm-first; invites **author + `@mentions` in the message + `CHAT_ALLOWED_USER_ID` (CEO) when set**. Then an **internal Redis queue** drives a Joanne **consumer** that posts **welcome + path question** in the **new channel** (not in `#humans`).
- **Human replies** in that channel with *new* / *existing* / *ideate* (natural language variants); Joanne branches into fixed guidance. **Ideate** may **auto-invite Tim** when `ONBOARDING_TIM_SLACK_USER_ID` / `TIM_SLACK_BOT_ID` / multiagent `tim` is configured—gated by `joanne-write-slack`, logged as `intent=onboarding_invite_tim`.
- **Do not conflate** with the hourly **channel-knowledge** digest job (different Redis keys and purpose).

## When to apply (doctrine / assistant)

- First messages after Joanne (or ops) creates a **new private/public channel** for a customer company.
- A user in **`#humans`** (or similar) says they are ready to start a company, with or without naming another human (`@` them).
- The user is unsure whether they are starting fresh, already have a business, or need ideation help.

## Outcomes to cover (pick one path, stay concise)

1. **New company** — They are starting something new; clarify one-line focus if volunteered. Squad: `@alex` `@tim` `@ross` `@garth` `@joanne` (sales, experiments/systems, build, research, exec ops).
2. **Existing company** — They already have a business; ask them to **paste context into the channel** (docs, links, positioning) from the prior company so agents are not working from memory alone.
3. **Need help shaping the idea** — **Tim** is the ideation lane; runtime may **invite** Tim to the channel when configured—otherwise suggest `@tim` explicitly.

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
