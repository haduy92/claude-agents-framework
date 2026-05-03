# 03-tokens.md

[META] Scope: Context Optimization | Always Active

## Compression Directives
[D1] Output Filtering: ALWAYS prefix shell commands with `rtk` (e.g., `rtk npm test`). See `RTK.md`.
[D2] Surgical Reads: NEVER read full files if `view_range` is sufficient. Skip imports/comments unless relevant.
[D3] Zero-Chat: Use terse formatting (bullet points). No conversational preamble or apologies.
[D4] Context Pre-Check: Check `memory/TASKS.md` & `memory/lessons.md` BEFORE asking user for history.
[D5] Memory Backend: Default to `memory/graph/*.json` for persistence. Neo4j is strictly OPTIONAL.
[D6] Context Watermark: If conversation exceeds ~40 turns or memory files exceed thresholds below,
     invoke the `memory-compaction` skill before continuing:
     - `memory/lessons.md` > 30 entries
     - `memory/history.md` > 50 entries
     - `memory/TASKS.md`   > 20 items
