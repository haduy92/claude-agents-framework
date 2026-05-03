# ADR-001: File-First Storage with Optional Neo4j

**Date:** 2026-05-03
**Status:** Accepted
**Deciders:** Framework authors

## Context

The framework needs to persist knowledge graph nodes (lessons, ingestion records, project metadata)
across Claude agent sessions. The initial design used Neo4j as the primary store, which introduced
a hard infrastructure dependency — sessions could not function if Neo4j was unavailable.

## Decision

Adopt a **file-first storage model** where `memory/graph/*.json` is the authoritative source of
truth. Neo4j is an optional enhancement for relational querying, not a requirement for basic
operation.

- Writes always go to `memory/graph/*.json` first (append-only, `id`-deduplicated).
- Neo4j sync is performed opportunistically via `scripts/neo4j-sync.{ps1,sh}` when the service
  is reachable.
- On sync: flushed nodes are removed from the JSON files. On failure: data remains in files.

## Consequences

**Positive:**
- Zero infrastructure required to start using the framework.
- Sessions remain fully functional without Docker or a running database.
- Simpler onboarding — `cp .env.template .env` is enough to begin.

**Negative:**
- File-based JSON cannot perform graph traversals natively.
- Large projects accumulate JSON that must be compacted periodically (see `memory-compaction` skill).
- Neo4j features (APOC procedures, relationship queries) are only available after sync.

## Alternatives Considered

- **Neo4j primary, file fallback:** Rejected — made the framework non-functional in offline/local
  environments and created a single point of failure.
- **SQLite instead of JSON:** Considered — SQLite provides better querying but adds a dependency.
  JSON files align better with Claude's native markdown-and-file world model.
