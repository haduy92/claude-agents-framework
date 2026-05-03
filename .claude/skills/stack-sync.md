# stack-sync.md

<metadata>
  <version>1.3</version>
  <skill_id>STACK_STATE_SYNC</skill_id>
</metadata>

<implementation>
  Real scripts live in `scripts/`:
  - Windows: `pwsh scripts/stack-sync.ps1 [--force]`
  - Unix/macOS: `bash scripts/stack-sync.sh [--force]`
</implementation>

<procedures>
  <step name="1_State_Hashing">
    - The script generates a SHA-256 hash of all dependency manifests (package.json, requirements.txt, go.mod, etc.).
    - It terminates early if the hash matches the one already stored in `.claude/rules/02-stack.md`.
  </step>
  <step name="2_Context_Anchor">
    - On hash mismatch, the script rebuilds `.claude/rules/02-stack.md` with detected language/library versions.
    - Align code generation logic to the detected versions recorded there.
  </step>
</procedures>