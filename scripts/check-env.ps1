#!/usr/bin/env pwsh
# check-env — Validates required .env variables before docker compose
# Usage: pwsh scripts/check-env.ps1

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ROOT = Split-Path -Parent $PSScriptRoot
$envFile = Join-Path $ROOT ".env"

if (-not (Test-Path $envFile)) {
    Write-Error "[check-env] .env not found. Run: cp .env.template .env"
    exit 1
}

$required = @{
    "NEO4J_PASSWORD" = "Required for Neo4j auth. Set a strong password."
    "NEO4J_URI"      = "Bolt connection URI. Default: bolt://localhost:7687"
    "NEO4J_USER"     = "Neo4j username. Default: neo4j"
}

$envVars = @{}
Get-Content $envFile | Where-Object { $_ -match '^\s*[^#]' -and $_ -match '=' } | ForEach-Object {
    $parts = $_ -split '=', 2
    $envVars[$parts[0].Trim()] = $parts[1].Trim()
}

$fail = $false
Write-Host "`n[check-env] Validating .env variables..." -ForegroundColor Cyan

foreach ($key in $required.Keys) {
    if (-not $envVars.ContainsKey($key) -or [string]::IsNullOrWhiteSpace($envVars[$key])) {
        Write-Host "  [MISSING] $key — $($required[$key])" -ForegroundColor Red
        $fail = $true
    } else {
        $display = if ($key -match "PASSWORD|SECRET|TOKEN") { "****" } else { $envVars[$key] }
        Write-Host "  [OK]      $key = $display" -ForegroundColor Green
    }
}

Write-Host ""
if ($fail) {
    Write-Error "[check-env] Missing required variables. Edit .env before running docker compose."
    exit 1
}
Write-Host "[check-env] All required variables set." -ForegroundColor Green
