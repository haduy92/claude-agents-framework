# 03-tokens.md

<version>1.0</version>
<scope>TOKEN_AND_CONTEXT_EFFICIENCY</scope>

## Token & Context Efficiency

These rules are **always active**. They apply to every session regardless of task type.

### Shell Commands
- Prefix shell commands with `rtk` for output compression: `rtk git status`, `rtk npm test`.
- See root `RTK.md` for the full prefix specification and compression levels.

### Large Outputs
- Never dump raw command output. Always pipe through `grep`, `head`, or `tail` to filter to relevant lines.
- Examples:
  - Logs: `rtk npm test 2>&1 | tail -40`
  - Directory listings: `Get-ChildItem src/ | Select-Object Name, Length`
  - Grep first, read file second: grep for the symbol before opening the whole file.

### File Reads
- When reading source files, **skip imports, boilerplate, and comments** unless they are directly relevant to the logic under analysis.
- For large files, use `view_range` to read only the relevant section — never read the entire file when a range will do.

### Background Context
- Before asking the user for context, check:
  1. `.claude/memory/` — recorded decisions and lessons
  2. `docs/decisions/` — architecture decision records (ADRs)
  3. `memory/TASKS.md` — current sprint and blockers
- Do NOT re-ask for information that is already recorded in these locations.

### Impact Analysis
- Before any major refactor, run `get_impact_radius` (code-review-graph MCP) to scope the blast radius.
- This avoids manual tracing and eliminates speculative file reads across unaffected modules.

### Response Compression
- `/caveman` activates **terse mode**. Three levels:
  - `full` — standard responses (default outside this project)
  - `lite` — bullet points only, no prose explanation
  - `ultra` — single-line status per action, no elaboration
- **This project defaults to `lite` via session hook.** Escalate to `ultra` during repair loops or
  high-frequency tool calls. Downgrade to `full` only when the user explicitly requests explanation.
