---
name: company-channel-onboarding
description: Use when Joanne is onboarding a new company Slack channel or when the user asks about creating a company channel, first-time company setup, or choosing existing vs new vs ideation in MakeACompany / BimRoss flows.
---

# Company channel onboarding (Joanne)

## Runtime (shipped)

- **Skill:** **`create-company`** / runtime tool **`joanne-create-company`** (confirm-first Slack write). Catalog requires **`name`**; **`founders`** is optional (defaults: message author; add others with `@mention`).
- **Invites:** **Author + `@mentions`** in the create request (Joanne bot mention stripped). With multiple candidates, a **Cogito structured extract** may narrow cofounders vs FYI pings; output is always limited to IDs present in the message. The channel is **created by the bot**, so **Joanne is already a member**; batch invites add human founders.
- After create, an **internal Redis queue** drives a Joanne **consumer** that posts **welcome + three questions** in the **new channel** (not in `#humans`).
- **Human replies** at **channel root** or **in a thread** (e.g. under the welcome message). slack-orchestrator routes onboarding-shaped plain messages (1/2/3 and the same keywords) to **Joanne** so they are not lost to random plain-message assignment. They can answer with **1 / 2 / 3** or natural language (**existing**, **new**, **idea**, and common variants). Joanne branches into fixed guidance.
- **Ideation (3):** Runtime may **auto-invite Tim** when `ONBOARDING_TIM_SLACK_USER_ID` / `TIM_SLACK_BOT_ID` / multiagent `tim` resolves—gated by `joanne-create-company`, logged as `intent=onboarding_invite_tim`.
- **Do not conflate** with the hourly **channel-knowledge** digest job (different Redis keys and purpose).

## When to apply (doctrine / assistant)

- First messages after Joanne creates a **new** private/public **company** channel.
- A user in **`#humans`** (or similar) says they are ready to start a company, optionally `@mention`ing cofounders in the **same** create-company message.
- The user is unsure whether they are starting fresh, already have a business, or need ideation help.

## Outcomes to cover (pick one path, stay concise)

Map to the **numbered** welcome where helpful:

1. **Existing company** — They already have a business; ask them to describe it and to **paste context into the channel** (docs, links, files). Emphasize that **notes accumulate in-channel** and the **squad learns** from what they share—not from memory alone.
2. **New company** — They want to **start** something new; ask them to describe the **company idea** in plain language. Squad: `@alex` `@tim` `@ross` `@garth` `@joanne` (sales, experiments/systems, build, research, exec ops).
3. **Need an idea / ideation** — **Tim** owns ideation; runtime may **invite** Tim when configured—otherwise suggest `@tim` explicitly.

## Tone

- Executive-ops calm: boundaries, clarity, no stacked asks.
- One clarifying question at a time unless the user already gave a full picture.
- Do not claim a full self-serve admin UI unless shipped; runtime registry is **JSON bootstrap + Redis HASH** (`docs/company-channels-redis.md` in employee-factory) merged at startup, with operator-assisted updates until the per-channel admin panel exists.

## Handoffs

- **Sales / offer / pricing** → suggest `@alex`.
- **Network / experiments / systems / ideation** → suggest `@tim`.
- **Build / infra / automation** → suggest `@ross`.
- **Research / synthesis** → suggest `@garth`.

## Related runtime docs

- Employee-factory: `docs/onboarding-company-channels.md`, `docs/company-channels-redis.md`, `docs/thread-routing.md`, `docs/channel-knowledge.md`.
