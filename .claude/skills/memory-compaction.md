# memory-compaction.md

[META] Skill: Memory Compaction | Trigger: Manual or auto-threshold

## Purpose
Prevent unbounded growth of `memory/lessons.md` and `memory/history.md` from degrading
session startup performance and consuming excess context window tokens.

## Trigger Conditions
Invoke this skill when ANY of the following are true:
- `memory/lessons.md` exceeds 30 entries
- `memory/history.md` exceeds 50 archive entries
- Session init is noticeably slow due to memory file size
- User explicitly requests compaction

## Procedure

### Step 1 — Compact lessons.md
1. Read all entries in `memory/lessons.md`.
2. Group entries by `Rule_Update` target (which rule file they propose updating).
3. For each group, write a single **digest paragraph** summarizing the pattern across entries.
   Format: `[DIGEST-NNN] <domain>: <summary of recurring failure pattern and corrective rule>.`
4. Replace the raw entries with the digest paragraphs.
5. Archive the raw entries to `memory/archive/lessons-YYYY-MM-DD.md`.

### Step 2 — Compact history.md
1. Read the Archive Ledger in `memory/history.md`.
2. Entries older than 90 days: collapse into a monthly summary line.
   Format: `[YYYY-MM] <N> tasks completed. Domains: <list>.`
3. Entries within 90 days: retain verbatim.
4. Rewrite `memory/history.md` with the compacted ledger.

### Step 3 — Context Watermark Check
After compaction, verify:
- `memory/lessons.md` < 30 entries ✓
- `memory/history.md` < 50 entries ✓
- Report token delta estimate: `(lines_before - lines_after) × ~8 tokens/line`

### Step 4 — Update TASKS.md
Remove all items with `[Verification: PASS]` from the verification queue.
If `TASKS.md` total items > 20, move completed backlog items to history.
