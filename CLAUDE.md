# CLAUDE.md

<metadata>
  <version>2.0</version>
  <status>ACTIVE</status>
  <rule_set>Lean-RTC_v2.0</rule_set>
</metadata>

<active_state>
  <!-- Auto-resolved on init — do NOT edit manually -->
  - Environment: [AUTO]
  - Verification_Level: [AUTO]
  - Stack_Hash: [AUTO]
</active_state>

<initialization>
  0. **Health Check:** Run `pwsh scripts/health-check.ps1` (Windows) or `bash scripts/health-check.sh` (Unix).
     On CRITICAL failures, halt and report to user. On WARN, proceed but surface warnings.

  1. **Auto-Detect Environment:** Run `git branch --show-current`.
     - `main` or `master` → PRODUCTION
     - `staging` or `release/*` → STAGING
     - Any other branch → DEVELOPMENT
     Update <active_state> with resolved values.

  2. **Stack Sync:** Run `pwsh scripts/stack-sync.ps1` (Windows) or `bash scripts/stack-sync.sh` (Unix).
     Updates `.claude/rules/02-stack.md`.

  3. **Verify State:** Read `memory/TASKS.md` and report active sprint.

  4. **Skill Loading (Lazy):** Load `skills/*.md` ONLY when procedure is explicitly needed.
</initialization>

<critical_governance>
  - **Tiered Execution:** Assess complexity (TIER 1/2/3). Tier 1 skips spec.md; Tier 2/3 requires it.
  - **Reproduction Mandate:** Every bug fix requires a Red-Green reproduction test.
  - **Zero-Chat:** Terse, bulleted output only. Apply `rtk` to all shell commands.
  - **Security:** If Environment is PRODUCTION, all destructive tools are LOCKED.
</critical_governance>

<project_status>
  - Current Task: [Refer to memory/TASKS.md]
  - Blockers: [None]
</project_status>

**Final Directive:** Plan first, verify always. Safety in production is the absolute priority.
Token efficiency is always active — see `.claude/rules/03-tokens.md` and `RTK.md`.
