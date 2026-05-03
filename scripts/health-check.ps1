#!/usr/bin/env pwsh
# health-check — Verifies framework integrity before session work begins
# Usage: pwsh scripts/health-check.ps1

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ROOT = Split-Path -Parent $PSScriptRoot
$PASS = 0; $WARN = 0; $FAIL = 0

function Check($label, $ok, $msg, [switch]$Critical) {
    if ($ok) {
        Write-Host "  [OK]   $label" -ForegroundColor Green
        $script:PASS++
    } elseif ($Critical) {
        Write-Host "  [FAIL] $label — $msg" -ForegroundColor Red
        $script:FAIL++
    } else {
        Write-Host "  [WARN] $label — $msg" -ForegroundColor Yellow
        $script:WARN++
    }
}

Write-Host "`n[health-check] Claude Agents Framework" -ForegroundColor Cyan
Write-Host "─────────────────────────────────────────"

# --- Required memory files ---
Write-Host "`nMemory files:"
foreach ($f in @("spec.md","TASKS.md","lessons.md","history.md")) {
    $path = Join-Path $ROOT "memory\$f"
    Check $f (Test-Path $path) "missing — create from template" -Critical
}

# --- Graph fallback directory ---
Write-Host "`nGraph fallback:"
$graphDir = Join-Path $ROOT "memory\graph"
Check "memory/graph/ exists" (Test-Path $graphDir) "run: mkdir memory\graph"
foreach ($f in @("lesson_nodes.json","ingestion_nodes.json","project_nodes.json")) {
    $path = Join-Path $graphDir $f
    Check $f (Test-Path $path) "missing — create with content: []"
}

# --- Rules files ---
Write-Host "`nRules:"
foreach ($f in @("00-scope.md","01-master.md","03-tokens.md")) {
    $path = Join-Path $ROOT ".claude\rules\$f"
    Check $f (Test-Path $path) "missing — critical rule file" -Critical
}

# --- Scripts executable ---
Write-Host "`nScripts:"
foreach ($f in @("stack-sync.ps1","neo4j-sync.ps1","check-env.ps1","health-check.ps1")) {
    $path = Join-Path $ROOT "scripts\$f"
    Check $f (Test-Path $path) "script missing"
}

# --- .env present ---
Write-Host "`nEnvironment:"
$envPath = Join-Path $ROOT ".env"
Check ".env exists" (Test-Path $envPath) "copy .env.template to .env and fill in values"
if (Test-Path $envPath) {
    $envContent = Get-Content $envPath -Raw
    Check "NEO4J_PASSWORD set" ($envContent -match 'NEO4J_PASSWORD=.+') "set NEO4J_PASSWORD in .env"
}

# --- Docker available ---
$dockerOk = $null -ne (Get-Command docker -ErrorAction SilentlyContinue)
Check "docker available" $dockerOk "install Docker Desktop"

# --- Summary ---
Write-Host "`n─────────────────────────────────────────"
Write-Host "  PASS: $PASS   WARN: $WARN   FAIL: $FAIL`n"

if ($FAIL -gt 0) {
    Write-Host "[health-check] CRITICAL issues found. Fix before starting session." -ForegroundColor Red
    exit 1
} elseif ($WARN -gt 0) {
    Write-Host "[health-check] Warnings present. Session can proceed." -ForegroundColor Yellow
    exit 0
} else {
    Write-Host "[health-check] All checks passed." -ForegroundColor Green
    exit 0
}
