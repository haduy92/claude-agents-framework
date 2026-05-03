# repair-protocol.md

<metadata>
  <version>1.2</version>
  <type>POST_FAILURE_RESOLUTION</type>
</metadata>

<procedures>
  <step name="1_Failure_Analysis">
    - If a verification test fails twice: **IMMEDIATE HALT**.
    - Compare failure logs with historical entries in memory/lessons.md.
  </step>

  <step name="2_The_Hypothesis">
    - Identify root cause (Environment, Dependency, or Logic). Draft a "Failure Hypothesis" in chat.
  </step>

  <step name="3_The_Final_Attempt">
    - Maximum attempts: 3. Propose final fix. If attempt 3 fails, mark task as **BLOCKED**.
  </step>

  <step name="4_Knowledge_Propagation">
    - **Mandatory:** Trigger the `memory-management` skill to promote lessons to rules and the graph.
  </step>
</procedures>