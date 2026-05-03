# CLAUDE.md

<metadata>
  <version>1.9</version>
  <status>ACTIVE</status>
  <rule_set>V1.5_MASTER</rule_set>
</metadata>

<active_state>
  <!-- Auto-resolved on init — do NOT edit manually -->
  - Environment: [AUTO]
  - Verification_Level: [AUTO]
  - Stack_Hash: [AUTO]
</active_state>

<initialization>
  1. **Auto-Detect Environment:** Run `git branch --show-current`.
     - `main` or `master` → PRODUCTION (Verification_Level: ADVERSARIAL)
     - `staging` or `release/*` → STAGING (Verification_Level: ADVERSARIAL)
     - Any other branch → DEVELOPMENT (Verification_Level: STANDARD)
     Update <active_state> with resolved values before any other action.

  2. **Stack Sync:** Run `pwsh scripts/stack-sync.ps1` (Windows) or `bash scripts/stack-sync.sh` (Unix).
     This hashes dependency manifests and updates `.claude/rules/02-stack.md`.
     Skip if the hash in `02-stack.md` already matches — the script handles this automatically.

  3. **Verify State:** Read `memory/TASKS.md` and report the active sprint and any blockers.

  4. **Skill Loading (Lazy):** Do NOT preload all skills. Load a skill only when its procedure is
     explicitly needed. Inject only the relevant `skills/*.md` content at that moment.
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
Token efficiency is always active — see `.claude/rules/03-tokens.md` and `RTK.md`.