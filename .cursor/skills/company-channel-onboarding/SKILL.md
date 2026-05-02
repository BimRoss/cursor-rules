---
name: company-channel-onboarding
description: Use when Joanne is onboarding a new company Slack channel or when the user asks about creating a company channel, first-time company setup, or choosing existing vs new vs ideation in MakeACompany / BimRoss flows.
---

# Company channel onboarding (Joanne)

## Runtime (shipped)

- **Skill:** **`create-company`** / runtime tool **`joanne-create-company`** (confirm-first Slack write). Catalog requires **`name`**; **`founders`** is optional (defaults: message author; add others with `@mention`).
- **Invites:** **Author + `@mentions`** in the create request (Joanne bot mention stripped). With multiple candidates, a **Cogito structured extract** may narrow cofounders vs FYI pings; output is always limited to IDs present in the message. The channel is **created by the bot**, so **Joanne is already a member**; batch invites add human founders.
- **Bot-invite path (default):** If a human invites Joanne into a **private** channel that is **not** yet in the Redis company-channel registry (and passes denylist / gates; **`create-company`** must be assigned), Joanne **registers** the channel and runs the **same** Redis onboarding consumer with **different** first-message copy (thanks + “setup in our systems…”), **no** `<!here>`, and **no** auto-invite of other bots—founders add the squad manually if they want.
- After create (or after that invite path), an **internal Redis queue** drives a Joanne **consumer** that posts **(1)** either the **create-company** welcome (channel name, company-workspace line, squad intro `<!here>`) or the **invite** thanks/setup lines, then **(2)** “Tell me, *FirstName*, …” (plain first name(s) for human founders from Slack profile—**not** `<@U…>`), the three numbered path prompts, and an optional **manage your company** link to `/{channelId}` on the MakeACompany web origin—in the **company channel** (not in `#humans`). On the create-company path, `<!here>` in **(1)** notifies the room; the “Tell me” line does not need user @mentions. That is the end of Joanne’s scripted onboarding; **no** follow-up bot messages from those numbered choices.
- **Slack-orchestrator** uses the same **plain-message** routing as any other channel message (`pickPlainResponder` / thread handoff), so whatever the user types next is handled by the normal architecture—not a special Joanne onboarding path.
- After the scripted welcome + “Tell me …” messages, Joanne **writes an initial channel-knowledge digest** to Redis (same markdown key as the hourly **channel-knowledge** refresh) so the founder portal transcript is not empty on first open; production still relies on the hourly CronJob (orchestrator token) to refresh all channels.

## When to apply (doctrine / assistant)

- First messages after Joanne creates a **new** private/public **company** channel.
- First scripted onboarding after Joanne was **invited** into a user-created **private** channel (when bot-join onboarding is enabled in env).
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
