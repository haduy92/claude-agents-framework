# RTK.md — Output Compression Prefix

`rtk` is a **shell output compression convention** for Claude agent sessions.
Prefixing a command with `rtk` signals the agent to apply output filtering before
surfacing results — reducing token consumption on verbose commands.

## Behaviour by Command Type

| Command Pattern | RTK Behaviour |
|---|---|
| `rtk git status` | Show only modified/untracked files; suppress branch verbosity |
| `rtk git diff` | Show stats summary (`--stat`) first; full diff only if explicitly needed |
| `rtk git log` | `--oneline --no-pager -20` by default |
| `rtk npm test` / `rtk pytest` | Surface only FAILED tests + final summary; suppress PASSED lines |
| `rtk npm install` / `rtk pip install` | Show final status line only; suppress download progress |
| `rtk docker compose up` | Tail only the last 20 lines of startup; suppress pull progress |
| `rtk find` / `rtk Get-ChildItem` | Limit to 50 results; suppress permission errors |
| `rtk cat` / `rtk Get-Content` | First 80 lines unless piped; warn if truncated |

## Compression Levels

Applied by `/caveman` terse mode (see `.claude/rules/03-tokens.md`):

| Level | Token Target | Behaviour |
|---|---|---|
| `full` | Baseline | No compression — standard output |
| `lite` | ~50% reduction | Bullet-point responses; `rtk` applied to all shell calls |
| `ultra` | ~80% reduction | Single-line status per action; errors only; no prose |

## Usage Examples

```bash
# Instead of:
git log --all --graph --decorate

# Use:
rtk git log
# Agent emits: git --no-pager log --oneline -20
```

```bash
# Instead of dumping full test output:
npm test

# Use:
rtk npm test
# Agent filters to failed tests + summary line only
```

## Notes
- `rtk` is an **agent-side instruction**, not a real CLI binary. The agent translates it into the
  appropriate filtered invocation at runtime.
- In terse mode (`lite`/`ultra`), the agent applies `rtk` behaviour automatically even without the prefix.
