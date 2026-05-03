# ADR-002: Tiered Task Execution Model (TIER 1/2/3)

**Date:** 2026-05-03
**Status:** Accepted
**Deciders:** Framework authors

## Context

The original framework required `memory/spec.md` to be `FINALIZED` before any implementation
could proceed. This was appropriate for large features but created unnecessary friction for small
refactors (renaming a variable, fixing a typo, adjusting a config value). The spec gate was being
bypassed informally, which undermined the entire governance model.

## Decision

Replace the binary "spec required / not required" gate with a **three-tier complexity model**:

| Tier | Criteria | Spec Required | Adversarial Review |
|---|---|---|---|
| TIER 1 | < 20 lines, no architectural impact | No | No |
| TIER 2 | > 20 lines or new dependencies | Yes (FINALIZED) | Yes ([M3]) |
| TIER 3 | Major architecture, destructive ops | Yes + User Approval | Yes ([M3]) |

**PRODUCTION override:** All tasks on `main`/`master` branch are treated as TIER 3 minimum,
regardless of size, enforced at session initialization.

## Consequences

**Positive:**
- Spec gate is respected because it's proportional — developers don't bypass it for trivial work.
- PRODUCTION protection is unconditional and automatic (branch-derived, not manually set).
- The adversarial review ([M3]) mandate is explicitly tied to spec finalization, closing the gap
  where specs could be marked FINALIZED without a quality review.

**Negative:**
- Requires judgment on tier classification. A task assessed as TIER 1 that turns out to be TIER 2
  must be escalated mid-execution.
- TIER 1 tasks that grow beyond 20 lines must trigger a retroactive spec (minor friction).

## Alternatives Considered

- **Single gate (original model):** Rejected — caused informal bypasses that undermined safety.
- **Two tiers (trivial / non-trivial):** Considered — simpler, but didn't distinguish between
  "feature needing spec" and "architecture needing user approval." Three tiers maps cleanly to
  the Architect / Engineer / QA persona model.
