# Agents & capabilities (living matrix)

**Purpose:** One place to see **persona** (cursor-rules bundle) vs **runtime** vs **tools** vs **auth** as BimRoss wires more employees. Update this when Slack, Cogito (employee-factory), or tooling changes.

| Agent | Rules prefix | Personality bundle | Slack chat | Cogito / worker | Planned tools (examples) | Auth / policy notes |
|-------|----------------|----------------------|------------|-----------------|--------------------------|---------------------|
| **Alex** | `alex-*.mdc` | `.cursor/personas/alex-personality.md` | Yes (employee-factory) | Yes | Gmail, calendar, … (policy in app) | Per-employee API keys / OAuth in secrets—not in persona |
| **Tim** | `tim-*.mdc` | `.cursor/personas/tim-personality.md` | Planned | Planned | Same pattern | Same |
| **Ross** | `ross-*.mdc` | `.cursor/personas/ross-personality.md` | Yes (employee-factory `EMPLOYEE_ID=ross`; **Head of Automation** persona) | Planned | Same pattern | Same |
| **Garth** | `garth-*.mdc` | `.cursor/personas/garth-personality.md` | Yes (employee-factory `EMPLOYEE_ID=garth`; **Head of Interns** persona) | Planned | Same pattern | Same |
| **Joanne** | `joanne-*.mdc` | `.cursor/personas/joanne-personality.md` | Yes (employee-factory `EMPLOYEE_ID=joanne`; **Head of Executive Operations** persona) | Planned | Email + Google Docs + capability desk | Same |

**Alex** is **Head of Sales**; **Tim** is **Head of Simplifying**; **Ross** is **Head of Automation** (first name Ross): technical leadership, shipping, infra—see **`ross-core.mdc`**. **Garth** is **Head of Interns**: eager intern lane—see **`garth-core.mdc`**.

**Cogito** = Go worker stack described in **employee-factory** (Socket Mode Slack today; extend with HTTP tools later).

**Persona** ships in **`geeemoney/cursor-rules`** image; **policy** stays in the worker + secret stores.

## Capability Contract Source Of Truth

Capability metadata now has a two-layer contract:

1. **Shared skill contract metadata** lives in **`slack-factory/skills-catalog.json`**:
   - core employees
   - skills by employee
   - required vs optional parameters per skill
   - runtime tool key per skill
2. **Runtime enablement** lives in **`employee-factory`** via **`EMPLOYEE_TOOLS`**:
   - which runtime tools are actually enabled for each employee in an environment

Joanne’s capability-desk output should read as: **catalog contract + runtime enablement**, not one without the other.
