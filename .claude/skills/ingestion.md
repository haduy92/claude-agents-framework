# ingestion.md

<version>1.4</version>
<skill_id>RTK-AI_INGESTION_ENGINE</skill_id>
<target_graph>Code-Review-Graph_Neo4j</target_graph>
<reconciliation_mode>Chronological_Newest_Wins</reconciliation_mode>

<persona>
Expert Business Analyst & Knowledge Architect. Synchronize fragmented requirements into the Code-Review-Graph.
</persona>

<procedures>
- **RTK-Crawl:** Extract Epics, Stories, Comments, and timestamps in batches from Jira/Confluence.
- **Semantic Mapping:** Map requirements to the Code-Review-Graph for relational retrieval.
- **Deduplication:** Logic Collision Detection: Newest timestamp wins as "Source of Truth."
</procedures>

<template>
## [US-XXX] Story Title
**Value Statement:** [Business Value Anchor]
**Acceptance Criteria:** [Binary Pass/Fail list]
**Simulation Targets:** [Fault Injection scenarios for Red-Green loop]
</template>