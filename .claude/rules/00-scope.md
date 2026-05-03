# 00-scope.md

[META] Scope: Safety & Guardrails | Anchor: CAVEMAN_PROXY

## Guardrails
[G1] DELETION: No DROP/TRUNCATE/DELETE on DBs without Tier 3 authorization.
[G2] MASS_RM: No 'rm -rf' outside 'temp/' or 'dist/'.
[G3] GIT: No force-push on protected branches.
[G4] SECRETS: No reading/transmitting .env or credentials.

## Proctor Logic
- Intercept: rm, delete, drop, sudo, chmod, git push --force.
- Action: Validate against Tier/Spec. REJECT if unauthorized.
