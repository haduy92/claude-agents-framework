#!/usr/bin/env bash
# stack-sync — Anchors the active stack state into .claude/rules/02-stack.md
# Usage: bash scripts/stack-sync.sh [--force]

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STACK_FILE="$ROOT/.claude/rules/02-stack.md"
FORCE=false
[[ "${1:-}" == "--force" ]] && FORCE=true

# --- 1. Hash dependency manifests ---
MANIFEST_FILES=$(find "$ROOT" \
    \( -name "package.json" -o -name "package-lock.json" \
    -o -name "requirements.txt" -o -name "pyproject.toml" -o -name "Pipfile.lock" \
    -o -name "go.mod" -o -name "go.sum" \
    -o -name "Cargo.toml" -o -name "Cargo.lock" \
    -o -name "pom.xml" -o -name "build.gradle" \
    -o -name "Gemfile" -o -name "Gemfile.lock" \) \
    -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/vendor/*" \
    | sort)

if [[ -z "$MANIFEST_FILES" ]]; then
    NEW_HASH="NO_MANIFESTS"
else
    NEW_HASH=$(echo "$MANIFEST_FILES" | xargs cat | sha256sum | awk '{print $1}')
fi

# --- 2. Early-terminate if hash unchanged ---
EXISTING_HASH=""
if [[ -f "$STACK_FILE" ]]; then
    EXISTING_HASH=$(grep -oP '(?<=<stack_hash>)[^<]+' "$STACK_FILE" || true)
fi

if [[ "$FORCE" != "true" && "$EXISTING_HASH" == "$NEW_HASH" ]]; then
    echo "[stack-sync] Hash unchanged (${NEW_HASH:0:12}...). No update needed."
    exit 0
fi

echo "[stack-sync] Hash changed. Rebuilding stack manifest..."

# --- 3. Detect stack ---
DETECTED=""

append() { DETECTED="${DETECTED}  - $1\n"; }

command -v node  &>/dev/null && append "Node.js: $(node --version)"
command -v npm   &>/dev/null && append "npm: $(npm --version)"
command -v python3 &>/dev/null && append "Python: $(python3 --version)"
command -v go    &>/dev/null && append "Go: $(go version | awk '{print $3}')"
command -v docker &>/dev/null && append "Docker: $(docker --version | awk '{print $3}' | tr -d ',')"

if [[ -f "$ROOT/package.json" ]] && command -v jq &>/dev/null; then
    while IFS= read -r line; do DETECTED="${DETECTED}${line}\n"; done < \
        <(jq -r '(.dependencies // {}) + (.devDependencies // {}) | to_entries[] | "  - \(.key): \(.value)"' "$ROOT/package.json" 2>/dev/null || true)
fi

if [[ -f "$ROOT/requirements.txt" ]]; then
    while IFS= read -r line; do
        [[ -z "$line" || "$line" == \#* ]] && continue
        append "$line"
    done < "$ROOT/requirements.txt"
fi

[[ -z "$DETECTED" ]] && DETECTED="  - (no managed dependencies detected)\n"

# --- 4. Write updated 02-stack.md ---
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
MANIFEST_COUNT=$(echo "$MANIFEST_FILES" | grep -c . || true)

cat > "$STACK_FILE" <<EOF
# 02-stack.md

<metadata>
  <last_sync>$TIMESTAMP</last_sync>
  <stack_hash>$NEW_HASH</stack_hash>
</metadata>

## Active Stack Manifest

$(printf "$DETECTED")
EOF

echo "[stack-sync] Stack manifest updated. Hash: ${NEW_HASH:0:12}..."
echo "[stack-sync] Manifests scanned: $MANIFEST_COUNT"
