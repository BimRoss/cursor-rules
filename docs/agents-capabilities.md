# Agents & capabilities (living matrix)

**Purpose:** One place to see **persona** (cursor-rules bundle) vs **runtime** vs **tools** vs **auth** as BimRoss wires more employees. Update this when Slack, Cogito (employee-factory), or tooling changes.

| Agent | Rules prefix | Personality bundle | Slack chat | Cogito / worker | Planned tools (examples) | Auth / policy notes |
|-------|----------------|----------------------|------------|-----------------|--------------------------|---------------------|
| **Alex** | `alex-*.mdc` | `.cursor/personas/alex-personality.md` | Yes (employee-factory) | Yes | Gmail, calendar, … (policy in app) | Per-employee API keys / OAuth in secrets—not in persona |
| **Tim** | `tim-*.mdc` | `.cursor/personas/tim-personality.md` | Planned | Planned | Same pattern | Same |
| **Ross** | `ross-*.mdc` | `.cursor/personas/ross-personality.md` | Yes (employee-factory `EMPLOYEE_ID=ross`; **CTO** persona) | Planned | Same pattern | Same |

**Ross** is the **CTO** (first name Ross): technical leadership, shipping, infra—see **`ross-core.mdc`**.

**Cogito** = Go worker stack described in **employee-factory** (Socket Mode Slack today; extend with HTTP tools later).

**Persona** ships in **`geeemoney/cursor-rules`** image; **policy** stays in the worker + secret stores.
