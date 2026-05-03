#!/usr/bin/env bash
# neo4j-sync — Flushes memory/graph/*.json pending nodes to Neo4j
# Usage: bash scripts/neo4j-sync.sh [--dry-run]

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GRAPH_DIR="$ROOT/memory/graph"
DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

# --- Load .env ---
ENV_FILE="$ROOT/.env"
if [[ ! -f "$ENV_FILE" ]]; then
    echo "[neo4j-sync] .env not found. Run: cp .env.template .env" >&2
    exit 1
fi
set -a; source "$ENV_FILE"; set +a

NEO4J_URI="${NEO4J_URI:-bolt://localhost:7687}"
NEO4J_USER="${NEO4J_USER:-neo4j}"
NEO4J_PASSWORD="${NEO4J_PASSWORD:-}"

if [[ -z "$NEO4J_PASSWORD" ]]; then
    echo "[neo4j-sync] NEO4J_PASSWORD is not set in .env" >&2
    exit 1
fi

# --- Test connectivity ---
echo "[neo4j-sync] Testing Neo4j connectivity..."
if ! cypher-shell -a "$NEO4J_URI" -u "$NEO4J_USER" -p "$NEO4J_PASSWORD" "RETURN 1" &>/dev/null; then
    echo "[neo4j-sync] Neo4j unreachable at $NEO4J_URI — skipping sync."
    exit 0
fi
echo "[neo4j-sync] Connected."

command -v jq &>/dev/null || { echo "[neo4j-sync] jq is required but not installed." >&2; exit 1; }

# --- Process each JSON node file ---
TOTAL_FLUSHED=0

for FILE in "$GRAPH_DIR"/*.json; do
    [[ -f "$FILE" ]] || continue
    NODE_COUNT=$(jq 'length' "$FILE")
    [[ "$NODE_COUNT" -eq 0 ]] && continue

    FLUSHED_IDS=()

    while IFS= read -r NODE; do
        ID=$(echo "$NODE"         | jq -r '.id')
        TYPE=$(echo "$NODE"       | jq -r '.type')
        PROPS=$(echo "$NODE"      | jq -c '.properties')
        CREATED=$(echo "$NODE"    | jq -r '.created_at')
        LINKS=$(echo "$NODE"      | jq -r '[.links[]? | "\"" + . + "\""] | join(", ")')

        CYPHER="MERGE (n:${TYPE} {id: '${ID}'})
SET n += ${PROPS}, n.created_at = '${CREATED}'
WITH n
UNWIND [${LINKS}] AS linkedId
  MATCH (m {id: linkedId})
  MERGE (n)-[:LINKED_TO]->(m);"

        if [[ "$DRY_RUN" == "true" ]]; then
            echo "[DRY-RUN] $CYPHER"
        else
            if echo "$CYPHER" | cypher-shell -a "$NEO4J_URI" -u "$NEO4J_USER" -p "$NEO4J_PASSWORD" &>/dev/null; then
                FLUSHED_IDS+=("$ID")
                ((TOTAL_FLUSHED++)) || true
            else
                echo "[neo4j-sync] Warning: failed to upsert node $ID" >&2
            fi
        fi
    done < <(jq -c '.[]' "$FILE")

    # Remove flushed nodes from file
    if [[ "$DRY_RUN" != "true" && ${#FLUSHED_IDS[@]} -gt 0 ]]; then
        FLUSHED_JSON=$(printf '%s\n' "${FLUSHED_IDS[@]}" | jq -R . | jq -s .)
        jq --argjson ids "$FLUSHED_JSON" '[.[] | select(.id as $id | $ids | index($id) | not)]' "$FILE" > "${FILE}.tmp"
        mv "${FILE}.tmp" "$FILE"
        echo "[neo4j-sync] $(basename "$FILE"): flushed ${#FLUSHED_IDS[@]} node(s)."
    fi
done

if [[ "$TOTAL_FLUSHED" -eq 0 && "$DRY_RUN" != "true" ]]; then
    echo "[neo4j-sync] Nothing to flush — graph files are empty."
elif [[ "$DRY_RUN" != "true" ]]; then
    echo "[neo4j-sync] Total flushed: $TOTAL_FLUSHED node(s)."
fi
