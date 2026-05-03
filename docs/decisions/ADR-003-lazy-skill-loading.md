# ADR-003: Lazy Skill Loading

**Date:** 2026-05-03
**Status:** Accepted
**Deciders:** Framework authors

## Context

Claude Code reads all files in `.claude/` at session initialization. The original framework had
all skills conceptually "active" at all times, meaning their full content was available in the
context window from the first message. With 6+ skill files averaging ~400 tokens each, this
front-loaded ~2,400+ tokens on every session regardless of which skills were actually used.

In long-running sessions (40+ turns), this baseline cost compounds: the initial context is
re-included in each API call, meaning unused skill files cost tokens continuously, not just once.

## Decision

Adopt **lazy skill loading**: skill files in `.claude/skills/` are not preloaded. A skill's
content is injected into context only at the moment its procedure is explicitly required.

The rule is codified in `CLAUDE.md` initialization step 4:
> "Load `skills/*.md` ONLY when procedure is explicitly needed."

## Consequences

**Positive:**
- Base context reduced by ~2,400 tokens per session (scales with number of skills).
- In a 50-turn session, this saves ~120,000 tokens across the session lifetime.
- Adding new skills has zero cost until they are invoked.

**Negative:**
- The agent must correctly identify when a skill is needed. Failure to invoke a skill means
  its procedure may be executed inconsistently from memory.
- Skills with cross-references (e.g., `memory-management` referencing `repair-protocol`) require
  both to be loaded for full fidelity.

## Mitigation

The `CLAUDE.md` initialization sequence explicitly names each skill and its trigger condition,
documented in the README skills table. This gives the agent sufficient signal to identify the
correct skill without needing all skill content in context simultaneously.

## Alternatives Considered

- **Eager loading (original):** Rejected — quadratic token cost in long sessions.
- **Single merged skills file:** Considered — reduces file I/O but defeats the purpose; the whole
  merged file would still be loaded eagerly. Lazy loading requires individual files.
