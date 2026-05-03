# stack-sync.md

<metadata>
  <version>1.2</version>
  <skill_id>GITNEXUS_STATE_SYNC</skill_id>
</metadata>

<procedures>
  <step name="1_State_Hashing">
    - Generate SHA-256 hash of manifests.
    - Terminate early if hash matches GitNexus Context_Anchor in CLAUDE.md.
  </step>
  <step name="2_Context_Anchor">
    - Update .claude/rules/02-stack.md to anchor current library versions.
    - Align code generation logic to detected versions.
  </step>
</procedures>