# memory-management.md

<metadata>
  <version>1.1</version>
  <type>CODE-REVIEW-GRAPH_SYNC</type>
  <priority_logic>Graph_First_Persistence</priority_logic>
</metadata>

<procedures>
  <step name="1_Immediate_Rule_Promotion">
    - **Trigger:** New entry in memory/lessons.md.
    - **Action:** Propose update to Rules. Automatically increment version numbers.
  </step>

  <step name="2_Graph_Persistence">
    - **Priority:** Convert lessons into Lesson_Nodes in Neo4j.
    - **Linkage:** Bind to Project_Node and Domain_Node.
  </step>

  <step name="3_Active_State_Archiving">
    - **Action:** Move COMPLETED assets to memory/archive/ and update memory/history.md summary.
    - **Pruning:** Remove completed items from TASKS.md to maintain focus.
  </step>
</procedures>

<logic_gates>
  - If memory/TASKS.md > 20 items, trigger mandatory archiving of completed items.
</logic_gates>