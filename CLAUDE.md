# CLAUDE.md

<metadata>
  <version>1.7</version>
  <status>ACTIVE</status>
  <engine>GitNexus_State_Anchor</engine>
  <rule_set>V1.4_MASTER</rule_set>
</metadata>

<active_state>
  - Environment: [DEVELOPMENT / STAGING / PRODUCTION] 
  - Verification_Level: [STANDARD / ADVERSARIAL]
  - Stack_Hash: [SHA-256 of dependency files]
  - Context_Anchor: [GitNexus_Active_Node]
</active_state>

<initialization>
  1. **Detect Environment:** Check active git branch and environment variables. Update <active_state>.
  2. **GitNexus Sync:** Execute `stack-sync` to anchor the context hash.
  3. **Verify State:** Confirm current task status in memory/TASKS.md.
</initialization>

<critical_governance>
  - **Caveman Proxy:** Implementation is strictly forbidden until memory/spec.md is FINALIZED.
  - **Reproduction Mandate:** Every bug fix requires a Red-Green reproduction test.
  - **Production Security:** If Environment is PRODUCTION, all destructive tools (delete, write, push) are LOCKED. Manual 2-step verification is mandatory.
  - **Repair Limit:** Max 3 attempts per task. Failures must trigger `repair-protocol`.
</critical_governance>

<project_status>
  - Current Task: [Refer to memory/TASKS.md]
  - Blockers: [None / List]
</project_status>

**Final Directive:** Plan first, verify always. Safety in production is the absolute priority.