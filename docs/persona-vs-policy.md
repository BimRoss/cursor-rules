# Persona vs policy

## Persona (this repo)

- **What:** Voice, frameworks, priorities—**`.mdc` rules** and rendered **`.cursor/personas/<name>-personality.md`** bundles.
- **Who edits:** Humans + agents following `<name>-factory.mdc` and review in PRs.
- **Public:** Safe for a public `cursor-rules` repo—no API keys, customer secrets, or private URLs.

## Policy (outside persona markdown)

- **What:** Hard limits on what an agent **may** do: OAuth scopes, send vs draft email, domain allowlists, rate limits, **audit logs** for tool calls.
- **Who edits:** Application code, env, secrets stores—not the personality file alone.
- **Why:** A model should not be the only gate between “user asked” and “enterprise Gmail sent.” Prompt instructions **supplement** policy; they do not replace it.

## Practical split

| Concern | Persona | Policy |
|--------|---------|--------|
| Tone, frameworks | Yes | No |
| “Prefer short replies in Slack” | Yes | Could also be app default |
| “May send email” | Hint only | **Code + config** |
| Which Google Workspace account | Never in public rules | Secrets / workload identity |

When you add tools (Gmail, internal APIs), document the **intent** in persona if useful; implement **enforcement** in the worker.

Roadmap narration (for example MakeACompany phase sequencing and live-vs-planned language) belongs in **persona doctrine**; runtime permissions and destructive boundaries still belong in **policy**.
