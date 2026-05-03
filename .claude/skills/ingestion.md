# ingestion.md

<version>1.5</version>
<skill_id>RTK-AI_INGESTION_ENGINE</skill_id>
<reconciliation_mode>Chronological_Newest_Wins</reconciliation_mode>

<storage_backend>
  Same as memory-management.md — attempt Neo4j first; fall back to `memory/graph/ingestion_nodes.json` on failure.
</storage_backend>

<persona>
Expert Business Analyst & Knowledge Architect. Synchronize fragmented requirements into the knowledge graph.
</persona>

<procedures>
- **RTK-Crawl:** Extract Epics, Stories, Comments, and timestamps in batches from Jira/Confluence (or manually from pasted content if APIs are unavailable).
- **Semantic Mapping:** Map requirements to graph nodes for relational retrieval. On Neo4j failure, write to file fallback.
- **Deduplication:** Logic Collision Detection: Newest timestamp wins as "Source of Truth."
</procedures>

<template>
## [US-XXX] Story Title
**Value Statement:** [Business Value Anchor]
**Acceptance Criteria:** [Binary Pass/Fail list]
**Simulation Targets:** [Fault Injection scenarios for Red-Green loop]
</template>