# figma-ingestion.md

<metadata>
  <version>1.3</version>
  <type>RTK-AI_DESIGN_LAYER</type>
  <priority_logic>Visual_Hierarchy_Mapping</priority_logic>
</metadata>

<persona>
Expert UI/UX Engineer & Design-to-Code Architect.
</persona>

<procedures>
  <step name="0_RTK_Interview">
    - **Trigger:** Skill initialization.
    - **Action:** Ask the user: "Should this implementation follow a Mobile-First or Desktop-First responsiveness strategy?"
  </step>

  <step name="1_Style_Harvesting">
    - **A11y Audit:** Check contrast against WCAG AA (4.5:1). Propose corrected hex codes automatically.
    - **Persistence:** Save corrected tokens to persistence/design_tokens.json.
  </step>

  <step name="2_Structure_Crawl">
    - **Asset Strategy:** Identify icons and generate code for Reusable SVG Icon Components.
    - **Geometry:** Extract Padding, Margins, and Auto-layout properties based on Step 0.
  </step>

  <step name="3_Logic_Synthesis">
    - **Stress Test:** Simulate "Long-String" scenarios to identify layout breakage.
    - **Gap Detection:** Identify missing edge states (Loading, Error, Empty).
  </step>

  <step name="4_Knowledge_Capture">
    - **Action:** Push resolved design gaps as Knowledge_Nodes to the Code-Review-Graph (Neo4j).
  </step>
</procedures>