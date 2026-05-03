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
│       ├── memory-management.md# Knowledge graph sync with file fallback
│       ├── repair-protocol.md  # Post-failure resolution (max 3 attempts)
│       └── stack-sync.md       # Stack hashing and manifest update
│
├── memory/
│   ├── spec.md                 # Active task specification (MUST be FINALIZED before coding)
│   ├── TASKS.md                # Backlog, active sprint, verification queue
│   ├── lessons.md              # Post-mortems → promoted to rules
│   ├── history.md              # Completed task archive ledger
│   └── graph/                  # Neo4j fallback — local JSON node store
│       ├── lesson_nodes.json
│       ├── ingestion_nodes.json
│       └── project_nodes.json
│
├── docs/
│   └── decisions/              # Architecture Decision Records (ADRs)
│
└── scripts/
    ├── stack-sync.ps1          # Windows: hash manifests, update 02-stack.md
    └── stack-sync.sh           # Unix/macOS: same
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

### 2. Start Neo4j

```bash
docker compose up -d
# Browser UI available at http://localhost:7474
# Bolt at bolt://localhost:7687
```

### 3. Open in Claude Code

Open the project root in [Claude Code](https://claude.ai/code). On session start the agent will
automatically:

1. Detect environment from the active git branch
2. Run `stack-sync` to hash dependency manifests
3. Report the active sprint from `memory/TASKS.md`

### 4. Start a task

```
Fill in memory/spec.md → set status to FINALIZED → ask the agent to begin
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
| `memory-management` | Archiving completed tasks or syncing lessons to the graph |
| `repair-protocol` | A verification test fails twice in a row |
| `stack-sync` | Dependency manifests have changed |

### Memory

`memory/` is the agent's **persistent working memory** across sessions.

| File | Purpose |
|---|---|
| `spec.md` | The active task specification. Implementation is blocked until `status: FINALIZED` |
| `TASKS.md` | Backlog + active sprint. Pruned when items exceed 20 |
| `lessons.md` | Failure post-mortems. New entries trigger rule promotion |
| `history.md` | Append-only ledger of completed work |
| `graph/` | File-based fallback when Neo4j is unreachable |

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

---

## Agent Workflow

```
┌─────────────────────────────────────────────────────────┐
│  SESSION START                                          │
│  1. Detect branch → resolve Environment + Verify Level  │
│  2. stack-sync → hash manifests → update 02-stack.md    │
│  3. Read TASKS.md → report active sprint                │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│  ARCHITECT PHASE  (spec.md status: DRAFT)               │
│  • Ingest requirements  [skill: ingestion]              │
│  • Write spec.md                                        │
│  • Adversarial review   [skill: adversarial]            │
│  • Finalize spec.md → status: FINALIZED                 │
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

**Fallback behaviour:** If Neo4j is unreachable, the agent writes nodes to `memory/graph/*.json`.
These are flushed to Neo4j automatically on the next session where the connection is restored.

---

## Safety & Governance

| Rule | Enforced by |
|---|---|
| No implementation before `spec.md: FINALIZED` | Caveman Proxy (`00-scope.md`) |
| No `DROP`, `DELETE`, `rm -rf`, force-push without spec auth | Caveman Proxy (`00-scope.md`) |
| No secrets read or transmitted | `00-scope.md` |
| PRODUCTION branch locks all destructive tools | `CLAUDE.md` auto-detection |
| Max 3 repair attempts before task is `BLOCKED` | `repair-protocol` skill |
| New failures → lessons promoted to rules | `memory-management` skill |

---

## Contributing

1. Add new skills to `.claude/skills/` — follow the existing XML metadata format.
2. Add new rules to `.claude/rules/` — prefix with the next number (`04-`, `05-`, ...).
3. Record architectural decisions in `docs/decisions/` as `ADR-NNN-title.md`
   ([MADR format](https://adr.github.io/madr/)).
4. After fixing a bug, add an entry to `memory/lessons.md` and propose a rule update.
