# 01-master.md

[META] Framework: Lean-RTC v2.0 | Policy: STRICT

## Task Execution Flow

1. Assess Task Complexity:
   - TIER 1 (Trivial/Refactor): < 20 lines, no arch impact. ACTION: Skip spec.md, proceed to Red-Green testing.
   - TIER 2 (Feature/Logic): > 20 lines or new dependencies. ACTION: Draft spec.md (FINALIZED required).
   - TIER 3 (Architecture/Destructive): Major changes, DB drops. ACTION: Spec.md + User Approval required.

   **PRODUCTION override:** If Environment = PRODUCTION, all tasks are treated as TIER 3 minimum,
   regardless of size. No exceptions.

2. Execution Mandates:
   - [M1] Red-Green Protocol: All fixes MUST be preceded by a failing test.
   - [M2] Pre-Tool Hooks:
     - Destructive (rm -rf, DROP): 3-point risk check against Spec.
     - Low-Risk (read, grep, ls): Zero preamble. Execute immediately.
   - [M3] Adversarial Gate: TIER 2 and TIER 3 specs MUST invoke the `adversarial` skill and resolve
     all HIGH-priority vectors before `status` may be set to FINALIZED. Skipping this gate is forbidden.
