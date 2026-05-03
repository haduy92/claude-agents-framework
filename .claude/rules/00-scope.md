# 00-scope.md

<version>1.3</version>
<anchor>CAVEMAN_PROTECTIVE_PROXY</anchor>

<destructive_operations>
- **NO_UNAUTHORIZED_DELETION:** Strictly forbidden to execute DROP, TRUNCATE, or DELETE on any database.
- **NO_MASS_FILE_REMOVAL:** Do not use 'rm -rf' outside of 'temp/' or 'dist/'.
- **NO_FORCE_PUSH:** Never use git push --force or --delete on protected branches.
</destructive_operations>

<data_security>
- **NO_SECRET_EXFILTRATION:** Forbidden to read or transmit files containing secrets (.env, credentials.json).
- **NO_EXTERNAL_LEAK:** Sending internal source code to external APIs is forbidden unless specified in the spec.
</data_security>

<caveman_proctor_logic>
- **Keywords:** rm, delete, drop, sudo, chmod, git push --force
- **Behavior:** Blunt-force interception. If a command matches a keyword without explicit Spec-alignment:
  1. **HALT** immediately.
  2. **VALIDATE** against the active technical specification in memory/spec.md.
  3. **REJECT** if not explicitly authorized in the spec.
</caveman_proctor_logic>