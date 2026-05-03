#!/usr/bin/env pwsh
# neo4j-sync — Flushes memory/graph/*.json pending nodes to Neo4j
# Usage: pwsh scripts/neo4j-sync.ps1

param(
    [switch]$DryRun  # Print Cypher statements without executing
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ROOT = Split-Path -Parent $PSScriptRoot
$GRAPH_DIR = Join-Path $ROOT "memory\graph"

# --- Load .env ---
$envFile = Join-Path $ROOT ".env"
if (-not (Test-Path $envFile)) {
    Write-Error "[neo4j-sync] .env not found. Run: cp .env.template .env"
    exit 1
}
Get-Content $envFile | Where-Object { $_ -match '^\s*[^#]' -and $_ -match '=' } | ForEach-Object {
    $parts = $_ -split '=', 2
    [System.Environment]::SetEnvironmentVariable($parts[0].Trim(), $parts[1].Trim())
}

$NEO4J_URI  = $env:NEO4J_URI  ?? "bolt://localhost:7687"
$NEO4J_USER = $env:NEO4J_USER ?? "neo4j"
$NEO4J_PASS = $env:NEO4J_PASSWORD

if (-not $NEO4J_PASS) {
    Write-Error "[neo4j-sync] NEO4J_PASSWORD is not set in .env"
    exit 1
}

# --- Test connectivity ---
Write-Host "[neo4j-sync] Testing Neo4j connectivity..." -ForegroundColor Cyan
$testResult = & cypher-shell -a $NEO4J_URI -u $NEO4J_USER -p $NEO4J_PASS "RETURN 1" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Warning "[neo4j-sync] Neo4j unreachable at $NEO4J_URI — skipping sync."
    exit 0
}
Write-Host "[neo4j-sync] Connected." -ForegroundColor Green

# --- Process each JSON node file ---
$jsonFiles = Get-ChildItem -Path $GRAPH_DIR -Filter "*.json" -ErrorAction SilentlyContinue
$totalFlushed = 0

foreach ($file in $jsonFiles) {
    $nodes = Get-Content $file.FullName -Raw | ConvertFrom-Json
    if (-not $nodes -or $nodes.Count -eq 0) { continue }

    $flushedIds = @()
    foreach ($node in $nodes) {
        $nodeType = $node.type
        $id       = $node.id
        $props    = $node.properties | ConvertTo-Json -Compress
        $links    = ($node.links | ForEach-Object { "'$_'" }) -join ", "

        $cypher = @"
MERGE (n:$nodeType {id: '$id'})
SET n += $props, n.created_at = '$($node.created_at)'
WITH n
UNWIND [$links] AS linkedId
  MATCH (m {id: linkedId})
  MERGE (n)-[:LINKED_TO]->(m);
"@

        if ($DryRun) {
            Write-Host "[DRY-RUN] $cypher" -ForegroundColor Yellow
        } else {
            $result = echo $cypher | & cypher-shell -a $NEO4J_URI -u $NEO4J_USER -p $NEO4J_PASS 2>&1
            if ($LASTEXITCODE -eq 0) {
                $flushedIds += $id
                $totalFlushed++
            } else {
                Write-Warning "[neo4j-sync] Failed to upsert node $id`: $result"
            }
        }
    }

    # Remove flushed nodes from file
    if (-not $DryRun -and $flushedIds.Count -gt 0) {
        $remaining = $nodes | Where-Object { $_.id -notin $flushedIds }
        $remaining | ConvertTo-Json -Depth 10 | Set-Content $file.FullName -Encoding UTF8
        Write-Host "[neo4j-sync] $($file.Name): flushed $($flushedIds.Count) node(s)." -ForegroundColor Green
    }
}

if ($totalFlushed -eq 0 -and -not $DryRun) {
    Write-Host "[neo4j-sync] Nothing to flush — graph files are empty." -ForegroundColor Gray
} elseif (-not $DryRun) {
    Write-Host "[neo4j-sync] Total flushed: $totalFlushed node(s)." -ForegroundColor Green
}
