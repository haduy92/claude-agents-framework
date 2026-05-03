# memory-management.md

<metadata>
  <version>1.3</version>
  <type>KNOWLEDGE_SYNC</type>
  <priority_logic>File_First_Neo4j_Optional</priority_logic>
</metadata>

<storage_backends>
  <primary name="file">
    - Path: `memory/graph/`
    - Format: One JSON file per node type: `lesson_nodes.json`, `project_nodes.json`, `domain_nodes.json`
    - Schema: `{ "id": "<uuid>", "type": "<NodeType>", "properties": {}, "links": ["<id>", ...], "created_at": "<ISO8601>" }`
    - Append-only. Deduplication key: `id`.
    - Always write here first. This is the source of truth.
  </primary>

  <optional name="neo4j">
    - URI: $NEO4J_URI (from .env)
    - Only sync if Neo4j is explicitly available (test: `RETURN 1` via cypher-shell).
    - On sync: flush `memory/graph/*.json` nodes to Neo4j, clear flushed entries from file.
    - On failure: skip silently — file backend already has the data.
  </optional>
</storage_backends>

<procedures>
  <step name="1_Immediate_Rule_Promotion">
    - **Trigger:** New entry in memory/lessons.md.
    - **Action:** Propose update to Rules. Automatically increment version numbers.
  </step>

  <step name="2_Graph_Persistence">
    - **Priority:** Attempt Neo4j write. On failure, write to file fallback.
    - **Linkage:** Bind Lesson_Nodes to Project_Node and Domain_Node.
    - **Neo4j sync check:** On next session start, if file fallback is non-empty and Neo4j is reachable,
      flush pending nodes to Neo4j and clear the fallback files.
  </step>

  <step name="3_Active_State_Archiving">
    - **Action:** Move COMPLETED assets to memory/archive/ and update memory/history.md summary.
    - **Pruning:** Remove completed items from TASKS.md to maintain focus.
  </step>
</procedures>

<logic_gates>
  - If memory/TASKS.md > 20 items, trigger mandatory archiving of completed items.
  - If memory/graph/*.json total size > 500KB, trigger Neo4j flush (or warn if Neo4j is unreachable).
</logic_gates>