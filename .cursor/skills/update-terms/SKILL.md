---
name: update-terms
description: Use when the user asks Joanne to show, read, review, or agree to the platform terms of use and terms and conditions (Make A Company / #humans legal consent). Triggers on update-terms, "agree to the terms", "terms and conditions", "terms of use", and similar. Joanne responds in the message thread with the same terms link, copy, and I Agree / I Do Not Agree controls as #humans onboarding; I Do Not Agree withdraws any prior acceptance until they agree again. Always use this skill when @joanne is asked about accepting terms, legal terms, or showing the terms link—not for business deal terms or generic "terms" in contracts unless clearly the platform user terms.
---

# Update terms (Joanne)

## Runtime (shipped)

- **Skill id:** `update-terms` / runtime tool **`joanne-update-terms`** (confirm-first in-thread; Block Kit).
- **Owner:** Joanne only; assign in the capability catalog / `employeeSkillIds` like other Joanne tools.
- **Behavior:** Posts the same threaded content as **#humans** first-join terms: link to `/{webOrigin}/terms`, *"Please read them, and then answer below."*, and **I Agree** / **I Do Not Agree** (primary/danger). Uses the same `terms_accept` confirmation task and profile keys as the join flow.
- **After I Agree:** Joanne posts a follow-up in-thread (same handler as #humans): `Thank you!  Your agreement is recorded.  When you're ready to start a company, just tell me.  Be sure to @ mention me with the request.` then `In the meantime, feel free to browse #humans for how folks typically interact with our team!` and shows the same two buttons as today.
- **Withdrawal:** **I Do Not Agree** clears `humans_terms_accepted_at` / `humans_terms_accepted_slack_message_ts` on the operator profile (when the slack→email index exists) so **slack-orchestrator** treats the user as not having accepted; squad agents stay gated until they agree again.

## When to apply (assistant / doctrine)

- User says they want to **agree to the terms**, **see the terms and conditions**, **re-read** or **review** platform terms, or names the tool **`update-terms`** / **update terms**.
- User completed onboarding earlier but wants the same consent UI again in-thread (any channel where Joanne is addressed per normal tool targeting).

## Do not confuse with

- **Business** "terms of a deal", payment terms, or contract negotiation — route to the right specialist; this skill is **platform** ToS / use terms only.
- **create-company** / company channel onboarding — different flow; **update-terms** only surfaces the legal consent card.

## Related code

- **employee-factory:** `skill_update_terms.go`, `humans_channel_join.go` (`humansTermsThreadSummary`, `handleHumansTermsConfirmationDecision`), `write_flow_confirmation.go` (`terms_accept`), `userprofile/terms_accepted.go`.
- **slack-orchestrator:** `termsredis` checker / message gating on `humans_terms_accepted_at`. While not accepted, the only human messages that are routed to any worker are **update-terms-shaped** text; the orchestrator sets `PreAcceptanceTermsBypass` and **Decide** sends **only Joanne** as the `update-terms` tool (no other agents). Broadcast @here / @channel roots stay blocked until accepted.
