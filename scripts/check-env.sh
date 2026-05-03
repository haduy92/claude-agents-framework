#!/usr/bin/env bash
# check-env — Validates required .env variables before docker compose
# Usage: bash scripts/check-env.sh

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$ROOT/.env"

if [[ ! -f "$ENV_FILE" ]]; then
    echo "[check-env] .env not found. Run: cp .env.template .env" >&2
    exit 1
fi

declare -A REQUIRED=(
    [NEO4J_PASSWORD]="Required for Neo4j auth. Set a strong password."
    [NEO4J_URI]="Bolt connection URI. Default: bolt://localhost:7687"
    [NEO4J_USER]="Neo4j username. Default: neo4j"
)

declare -A ENV_VARS=()
while IFS='=' read -r key val; do
    [[ -z "$key" || "$key" =~ ^# ]] && continue
    ENV_VARS["${key// /}"]="${val:-}"
done < "$ENV_FILE"

FAIL=false
echo ""
echo "[check-env] Validating .env variables..."

for key in "${!REQUIRED[@]}"; do
    val="${ENV_VARS[$key]:-}"
    if [[ -z "$val" ]]; then
        echo "  [MISSING] $key — ${REQUIRED[$key]}"
        FAIL=true
    else
        [[ "$key" =~ PASSWORD|SECRET|TOKEN ]] && display="****" || display="$val"
        echo "  [OK]      $key = $display"
    fi
done

echo ""
if [[ "$FAIL" == "true" ]]; then
    echo "[check-env] Missing required variables. Edit .env before running docker compose." >&2
    exit 1
fi
echo "[check-env] All required variables set."
