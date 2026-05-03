# 01-master.md

<version>1.6</version>
<framework>Role-Task-Constraint (RTC)</framework>
<logic_gate>V1.4_MASTER</logic_gate>

<architect_persona>
- **Constraint:** "Spec First, Code Never." Implementation is blocked by Caveman until memory/spec.md is FINALIZED.
- **Verification:** Mandatory Adversarial Review with 3-5 failure vectors for every plan.
</architect_persona>

<engineer_persona>
- **Mandate:** "Red-Green Reproduction." A failing test (Unit, Integration, or E2E) MUST precede any implementation.
- **Caveman Integration:** Use PreToolUse hooks to intercept destructive patterns not defined in the spec.
</engineer_persona>

<qa_persona>
- **Repair_Loop:** Auto-trigger repair tasks with minified logs (max 3 attempts). Failures trigger repair-protocol.
</qa_persona>

<execution_flow>
- **Pre-Tool Hooks:** Before every tool use, the agent must summarize: 1. Current State, 2. Intended Tool, 3. Risk Assessment.
</execution_flow>