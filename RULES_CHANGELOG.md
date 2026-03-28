# Rules Changelog

Tracks meaningful updates to `.cursor/rules` and `.cursor/skills` so guidance improves over time with visible rationale.

## Entry format

Use this template for each entry:

```markdown
## YYYY-MM-DD - Short title
- Trigger: what problem or repeated failure prompted this change
- Change: what rule/skill was added, removed, or modified
- Expected impact: what should improve (speed, quality, fewer retries, safer behavior)
- Verification: how to confirm impact (audit script, lint/test signal, fewer incidents)
```

## 2026-03-27 - Self-healing baseline + audits
- Trigger: need stronger autonomous recovery and learning loops for Cursor rules.
- Change: added `self-healing-self-learning-loop.mdc`, `rules-audit-and-pruning.mdc`, `rules-lifecycle-reviewby.mdc`, audit/scorecard scripts, and CI workflow.
- Expected impact: fewer blind retries, cleaner rule set, faster drift detection, and measurable hygiene.
- Verification: `./scripts/audit-rules.sh`, `./scripts/rules-scorecard.sh`, and passing `Rules Audit` GitHub Action.

## 2026-03-27 - Lifecycle metadata activation
- Trigger: lifecycle policy existed but was not measurable in active rules.
- Change: added `reviewBy` to key always-apply governance rules and updated audit checks to warn specifically on always-apply rules missing `reviewBy`.
- Expected impact: focused maintenance reminders with less warning noise.
- Verification: audit warning count trends down over time while critical always-apply rules carry `reviewBy`.

## 2026-03-27 - Always-apply reviewBy completion
- Trigger: remaining audit warnings on always-apply rules missing lifecycle metadata.
- Change: added `reviewBy` to all tracked always-apply rules and excluded private `local-context.mdc` from `reviewBy` warnings.
- Expected impact: clean audit output with explicit lifecycle review dates on mandatory rules.
- Verification: `./scripts/audit-rules.sh` shows zero warnings for tracked always-apply rules.

## 2026-03-27 - Risk-tiered review cadence
- Trigger: one shared `reviewBy` date was too coarse for mixed-risk rules.
- Change: staggered `reviewBy` dates by risk (`2026-05-31` for operational/safety rules, `2026-06-30` for governance defaults, `2026-09-30` for stable persona guidance).
- Expected impact: faster refresh on high-risk guidance without creating unnecessary churn on stable rules.
- Verification: `reviewBy` values align with rule criticality and audit remains warning-free.

## 2026-03-27 - Complex topics require web research
- Trigger: explicit request to reduce stale assumptions on remotely complex topics.
- Change: added always-apply rule `web-research-for-complex-topics.mdc` requiring web research before final guidance on non-trivial, high-impact, or fast-moving topics.
- Expected impact: higher decision accuracy, fewer outdated recommendations, and better risk handling on architecture/security/ops choices.
- Verification: on complex tasks, agent behavior includes web lookup before final recommendations; rule is tracked with `reviewBy`.
