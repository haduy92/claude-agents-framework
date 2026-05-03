#!/usr/bin/env bash
# health-check — Verifies framework integrity before session work begins
# Usage: bash scripts/health-check.sh

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASS=0; WARN=0; FAIL=0

check() {
    local label="$1" ok="$2" msg="$3" critical="${4:-false}"
    if [[ "$ok" == "true" ]]; then
        echo "  [OK]   $label"; ((PASS++)) || true
    elif [[ "$critical" == "true" ]]; then
        echo "  [FAIL] $label — $msg"; ((FAIL++)) || true
    else
        echo "  [WARN] $label — $msg"; ((WARN++)) || true
    fi
}

echo ""
echo "[health-check] Claude Agents Framework"
echo "─────────────────────────────────────────"

# --- Required memory files ---
echo ""
echo "Memory files:"
for f in spec.md TASKS.md lessons.md history.md; do
    [[ -f "$ROOT/memory/$f" ]] && ok="true" || ok="false"
    check "$f" "$ok" "missing — create from template" "true"
done

# --- Graph fallback directory ---
echo ""
echo "Graph fallback:"
[[ -d "$ROOT/memory/graph" ]] && ok="true" || ok="false"
check "memory/graph/ exists" "$ok" "run: mkdir -p memory/graph"
for f in lesson_nodes.json ingestion_nodes.json project_nodes.json; do
    [[ -f "$ROOT/memory/graph/$f" ]] && ok="true" || ok="false"
    check "$f" "$ok" "missing — create with content: []"
done

# --- Rules files ---
echo ""
echo "Rules:"
for f in 00-scope.md 01-master.md 03-tokens.md; do
    [[ -f "$ROOT/.claude/rules/$f" ]] && ok="true" || ok="false"
    check "$f" "$ok" "missing — critical rule file" "true"
done

# --- Scripts ---
echo ""
echo "Scripts:"
for f in stack-sync.sh neo4j-sync.sh check-env.sh health-check.sh; do
    [[ -f "$ROOT/scripts/$f" ]] && ok="true" || ok="false"
    check "$f" "$ok" "script missing"
done

# --- .env ---
echo ""
echo "Environment:"
[[ -f "$ROOT/.env" ]] && ok="true" || ok="false"
check ".env exists" "$ok" "copy .env.template to .env and fill in values"
if [[ -f "$ROOT/.env" ]]; then
    grep -q 'NEO4J_PASSWORD=.\+' "$ROOT/.env" && ok="true" || ok="false"
    check "NEO4J_PASSWORD set" "$ok" "set NEO4J_PASSWORD in .env"
fi

# --- Docker ---
command -v docker &>/dev/null && ok="true" || ok="false"
check "docker available" "$ok" "install Docker"

# --- Summary ---
echo ""
echo "─────────────────────────────────────────"
echo "  PASS: $PASS   WARN: $WARN   FAIL: $FAIL"
echo ""

if [[ "$FAIL" -gt 0 ]]; then
    echo "[health-check] CRITICAL issues found. Fix before starting session."
    exit 1
elif [[ "$WARN" -gt 0 ]]; then
    echo "[health-check] Warnings present. Session can proceed."
    exit 0
else
    echo "[health-check] All checks passed."
    exit 0
fi
