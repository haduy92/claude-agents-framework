# claude-agents-framework

A **Claude Code agent configuration framework** for structured, production-safe AI agent pipelines.
Provides governed workflows, token-optimized context management, fault-resilient memory, and a
knowledge graph backend — all driven through markdown rules and skills that Claude reads natively.

---

## Table of Contents

- [Philosophy](#philosophy)
- [Project Structure](#project-structure)
- [Quick Start](#quick-start)
- [Core Concepts](#core-concepts)
  - [Rules](#rules)
  - [Skills](#skills)
  - [Memory](#memory)
  - [Token Efficiency](#token-efficiency)
- [Scripts Reference](#scripts-reference)
- [Agent Workflow](#agent-workflow)
- [Neo4j Knowledge Graph](#neo4j-knowledge-graph)
- [Safety & Governance](#safety--governance)
- [Contributing](#contributing)

---

## Philosophy

> **Plan first, verify always. Safety in production is the absolute priority.**

This framework enforces three principles on every Claude agent session:

1. **Spec-gated execution** — no implementation until `memory/spec.md` is `FINALIZED`.
2. **Red-Green discipline** — every bug fix is preceded by a failing reproduction test.
3. **Token efficiency** — lazy skill loading, tiered pre-tool hooks, and output compression keep
   context lean across long sessions.

---

## Project Structure

```
claude-agents-framework/
│
├── CLAUDE.md                   # Agent bootstrap: env detection, init sequence, governance
├── RTK.md                      # Output compression prefix reference
├── docker-compose.yml          # Neo4j knowledge graph service
├── .env.template               # Environment variable template
│
├── .claude/
│   ├── rules/                  # Always-loaded behavioral constraints
│   │   ├── 00-scope.md         # Caveman Proxy — destructive operation guard
│   │   ├── 01-master.md        # RTC personas, tiered pre-tool hooks
│   │   ├── 02-stack.md         # Auto-generated stack manifest (git-ignored)
│   │   └── 03-tokens.md        # Token & context efficiency rules
│   │
│   └── skills/                 # Lazy-loaded procedural skills
│       ├── adversarial.md      # Adversarial QA — failure vector analysis
│       ├── figma-ingestion.md  # Design-to-code ingestion pipeline
│       ├── ingestion.md        # Requirements ingestion from Jira/Confluence
│       ├── memory-compaction.md# Context window compaction and history digest
│       ├── memory-management.md# Knowledge graph sync with file fallback
│       ├── repair-protocol.md  # Post-failure resolution (max 3 attempts)
│       └── stack-sync.md       # Stack hashing and manifest update
│
├── memory/
│   ├── spec.md                 # Active task specification (MUST be FINALIZED before coding)
│   ├── TASKS.md                # Backlog, active sprint, verification queue, blocked items
│   ├── lessons.md              # Post-mortems → promoted to rules
│   ├── history.md              # Completed task archive ledger
│   └── graph/                  # File-first node store (source of truth)
│       ├── lesson_nodes.json
│       ├── ingestion_nodes.json
│       └── project_nodes.json
│
├── docs/
│   └── decisions/              # Architecture Decision Records (ADRs)
│       ├── ADR-001-file-first-storage.md
│       ├── ADR-002-tiered-execution-model.md
│       └── ADR-003-lazy-skill-loading.md
│
├── .github/
│   └── workflows/
│       └── lint.yml            # CI: validates rules, skills, scripts, docker-compose
│
└── scripts/                    # See Scripts Reference section below
    ├── check-env.ps1 / .sh     # [MANUAL] Validate .env before docker compose
    ├── health-check.ps1 / .sh  # [AUTO] Framework integrity check on session start
    ├── neo4j-sync.ps1 / .sh    # [MANUAL] Flush memory/graph/*.json to Neo4j
    └── stack-sync.ps1 / .sh    # [AUTO] Hash manifests, update 02-stack.md
```

---

## Quick Start

### 1. Clone and configure

```bash
git clone https://github.com/haduy92/claude-agents-framework.git
cd claude-agents-framework
cp .env.template .env
# Edit .env — set NEO4J_PASSWORD
```

### 2. Validate environment

Before starting any services, verify your `.env` is complete:

```bash
# Windows
pwsh scripts/check-env.ps1

# Unix/macOS
bash scripts/check-env.sh
```

### 3. Start Neo4j

```bash
docker compose up -d
# Browser UI available at http://localhost:7474
# Bolt at bolt://localhost:7687
```

### 4. Open in Claude Code

Open the project root in [Claude Code](https://claude.ai/code). On session start the agent will
automatically:

1. Run `health-check` — verifies memory files, graph dir, rules, `.env`, and docker
2. Detect environment from the active git branch
3. Run `stack-sync` to hash dependency manifests
4. Report the active sprint from `memory/TASKS.md`

### 5. Start a task

```
Fill in memory/spec.md → run adversarial review (TIER 2/3) → set status to FINALIZED → ask the agent to begin
```

---

## Core Concepts

### Rules

Rules in `.claude/rules/` are **always loaded** at session start. They form the immutable
behavioral contract for the agent.

| File | Purpose |
|---|---|
| `00-scope.md` | Blocks destructive ops (`DROP`, `rm -rf`, force-push) without spec authorization |
| `01-master.md` | RTC persona model (Architect / Engineer / QA) + tiered pre-tool hooks |
| `02-stack.md` | Auto-generated; tracks detected language/library versions |
| `03-tokens.md` | Token efficiency rules: `rtk` prefix, output filtering, lazy reads |

### Skills

Skills in `.claude/skills/` are **lazy-loaded** — injected into context only when the agent needs
to execute that procedure. This keeps the base context small.

| Skill | Invoke when... |
|---|---|
| `adversarial` | Reviewing a spec for failure vectors |
| `ingestion` | Syncing requirements from Jira/Confluence |
| `figma-ingestion` | Translating a Figma design into code |
| `memory-compaction` | Context watermark hit (lessons > 30, history > 50, tasks > 20) |
| `memory-management` | Archiving completed tasks or syncing lessons to the graph |
| `repair-protocol` | A verification test fails twice in a row |
| `stack-sync` | Dependency manifests have changed |

### Memory

`memory/` is the agent's **persistent working memory** across sessions.

| File | Purpose |
|---|---|
| `spec.md` | The active task specification. Implementation is blocked until `status: FINALIZED` |
| `TASKS.md` | Backlog + active sprint. Blocked items escalate to user after 2 sessions |
| `lessons.md` | Failure post-mortems. New entries trigger rule promotion. Compacted at > 30 entries |
| `history.md` | Append-only ledger of completed work. Compacted at > 50 entries |
| `graph/` | File-first node store — source of truth; optionally synced to Neo4j |

### Token Efficiency

The framework applies several layers of compression to keep sessions lean:

- **`rtk` prefix** — signals the agent to filter verbose command output (see [`RTK.md`](./RTK.md))
- **Lazy skill loading** — skills are never preloaded; injected only on demand
- **Tiered pre-tool hooks** — read-only tools proceed with no preamble; destructive tools require
  full 3-point risk assessment
- **`/caveman` terse mode** — activates compressed responses (`lite` by default in this project)
- **`view_range` reads** — agent reads only relevant file sections, skipping imports/boilerplate
- **Background context check** — agent checks `memory/` and `docs/decisions/` before asking the
  user for context
- **Context watermark** — at conversation turn ~40 or memory threshold, `memory-compaction` skill
  is invoked to digest old entries and reclaim context window space

---

## Scripts Reference

Scripts are split into two categories: **automatic** (run by the agent on session start) and
**manual** (run by you when needed).

### Automatic — run by the agent

| Script | Trigger | What it does |
|---|---|---|
| `health-check.ps1` / `.sh` | Session start (step 0) | Validates memory files, graph dir, rule files, `.env`, docker. Halts on CRITICAL failures. |
| `stack-sync.ps1` / `.sh` | Session start (step 2) | SHA-256 hashes dependency manifests. Rebuilds `02-stack.md` only if hash changed. |

You can also run these manually to verify framework state:

```bash
# Windows
pwsh scripts/health-check.ps1
pwsh scripts/stack-sync.ps1          # add --force to skip hash check

# Unix/macOS
bash scripts/health-check.sh
bash scripts/stack-sync.sh           # add --force to skip hash check
```

### Manual — run by you

#### `check-env` — validate `.env` before starting services

Run this once after copying `.env.template` to `.env`, and again whenever you change env vars.

```bash
# Windows
pwsh scripts/check-env.ps1

# Unix/macOS
bash scripts/check-env.sh
```

Expected output on success:
```
[check-env] Validating .env variables...
  [OK]      NEO4J_URI = bolt://localhost:7687
  [OK]      NEO4J_USER = neo4j
  [OK]      NEO4J_PASSWORD = ****
[check-env] All required variables set.
```

#### `neo4j-sync` — flush file nodes to Neo4j

Run this when Neo4j is running and you want to sync accumulated `memory/graph/*.json` nodes into
the graph database. The script connects, upserts all pending nodes, and removes flushed entries
from the JSON files.

```bash
# Windows
pwsh scripts/neo4j-sync.ps1           # live sync
pwsh scripts/neo4j-sync.ps1 -DryRun   # preview Cypher without executing

# Unix/macOS
bash scripts/neo4j-sync.sh            # live sync
bash scripts/neo4j-sync.sh --dry-run  # preview Cypher without executing
```

> **Note:** `neo4j-sync` requires `cypher-shell` to be available on your PATH (included with
> Neo4j). If Neo4j is not reachable, the script exits cleanly without modifying any files.

---

## Agent Workflow

```
┌─────────────────────────────────────────────────────────┐
│  SESSION START                                          │
│  0. health-check → verify files, env, docker           │
│  1. Detect branch → resolve Environment                 │
│  2. stack-sync → hash manifests → update 02-stack.md   │
│  3. Read TASKS.md → report active sprint                │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│  ARCHITECT PHASE  (spec.md status: DRAFT)               │
│  • Ingest requirements  [skill: ingestion]              │
│  • Write spec.md                                        │
│  • Adversarial review   [skill: adversarial] ← [M3]    │
│  • Fill approvals block → set status: FINALIZED         │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│  ENGINEER PHASE   (Caveman gate lifted)                 │
│  • Write failing test (Red)                             │
│  • Implement to pass test (Green)                       │
│  • Scope refactors with get_impact_radius               │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│  QA PHASE                                               │
│  • Run verification suite                               │
│  • On failure (×2): repair-protocol [skill: repair]     │
│  • On pass: archive task, sync lessons to graph         │
└─────────────────────────────────────────────────────────┘
```

---

## Neo4j Knowledge Graph

The framework persists lessons, requirements, and project nodes in a Neo4j graph for relational
retrieval across sessions.

**Start the service:**

```bash
docker compose up -d
```

**Connection defaults** (override in `.env`):

| Variable | Default |
|---|---|
| `NEO4J_URI` | `bolt://localhost:7687` |
| `NEO4J_USER` | `neo4j` |
| `NEO4J_PASSWORD` | *(required — set in `.env`)* |

**Fallback behaviour:** Nodes are always written to `memory/graph/*.json` first (source of truth).
Neo4j is optional — run `neo4j-sync` manually to flush file nodes into the graph when Neo4j is available.

---

## Safety & Governance

| Rule | Enforced by |
|---|---|
| No implementation before `spec.md: FINALIZED` | Caveman Proxy (`00-scope.md`) |
| TIER 2/3 specs must pass adversarial review before FINALIZED | [M3] mandate (`01-master.md`) |
| No `DROP`, `DELETE`, `rm -rf`, force-push without spec auth | Caveman Proxy (`00-scope.md`) |
| No secrets read or transmitted | `00-scope.md` |
| PRODUCTION branch → all tasks TIER 3, destructive tools LOCKED | `CLAUDE.md` + `01-master.md` |
| Max 3 repair attempts before task is `BLOCKED` | `repair-protocol` skill |
| BLOCKED tasks escalate to user after 2 sessions | `TASKS.md` blocked section |
| New failures → lessons promoted to rules | `memory-management` skill |

---

## Contributing

1. Add new skills to `.claude/skills/` — follow the existing XML metadata format.
2. Add new rules to `.claude/rules/` — prefix with the next number (`04-`, `05-`, ...).
3. Record architectural decisions in `docs/decisions/` as `ADR-NNN-title.md`
   ([MADR format](https://adr.github.io/madr/)).
4. After fixing a bug, add an entry to `memory/lessons.md` and propose a rule update.
5. After adding a new script, update the [Scripts Reference](#scripts-reference) section and
   classify it as `[AUTO]` or `[MANUAL]` in the project structure tree.
