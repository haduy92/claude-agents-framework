#!/usr/bin/env pwsh
# stack-sync — Anchors the active stack state into .claude/rules/02-stack.md
# Usage: pwsh scripts/stack-sync.ps1

param(
    [switch]$Force  # Skip hash comparison and always update
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ROOT = Split-Path -Parent $PSScriptRoot
$STACK_FILE = Join-Path $ROOT ".claude\rules\02-stack.md"

# --- 1. Hash dependency manifests ---
$MANIFEST_PATTERNS = @(
    "package.json", "package-lock.json",
    "requirements.txt", "pyproject.toml", "Pipfile.lock",
    "go.mod", "go.sum",
    "Cargo.toml", "Cargo.lock",
    "pom.xml", "build.gradle",
    "Gemfile", "Gemfile.lock",
    "composer.json", "composer.lock"
)

$manifestFiles = @()
foreach ($pattern in $MANIFEST_PATTERNS) {
    $found = Get-ChildItem -Path $ROOT -Filter $pattern -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch "node_modules|vendor|\.git" }
    $manifestFiles += $found
}

if ($manifestFiles.Count -eq 0) {
    Write-Warning "No dependency manifests found. Stack hash will be empty."
    $newHash = "NO_MANIFESTS"
} else {
    $combined = ($manifestFiles | Sort-Object FullName | ForEach-Object {
        Get-Content $_.FullName -Raw
    }) -join ""
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($combined)
    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    $hashBytes = $sha256.ComputeHash($bytes)
    $newHash = ($hashBytes | ForEach-Object { $_.ToString("x2") }) -join ""
    $sha256.Dispose()
}

# --- 2. Read existing hash and early-terminate if unchanged ---
$existingHash = ""
if (Test-Path $STACK_FILE) {
    $content = Get-Content $STACK_FILE -Raw
    if ($content -match '<stack_hash>([^<]+)</stack_hash>') {
        $existingHash = $Matches[1].Trim()
    }
}

if (-not $Force -and $existingHash -eq $newHash) {
    Write-Host "[stack-sync] Hash unchanged ($($newHash.Substring(0,12))...). No update needed." -ForegroundColor Green
    exit 0
}

Write-Host "[stack-sync] Hash changed. Rebuilding stack manifest..." -ForegroundColor Cyan

# --- 3. Detect stack ---
$detected = [System.Collections.Generic.List[string]]::new()

function Detect-Version($file, $pattern) {
    if (Test-Path $file) {
        $c = Get-Content $file -Raw -ErrorAction SilentlyContinue
        if ($c -match $pattern) { return $Matches[1] }
    }
    return $null
}

# Node.js
$nodeVer = & node --version 2>$null; if ($LASTEXITCODE -eq 0) { $detected.Add("  - Node.js: $nodeVer") }
$npmVer  = & npm --version 2>$null;  if ($LASTEXITCODE -eq 0) { $detected.Add("  - npm: $npmVer") }

$pkgJson = Join-Path $ROOT "package.json"
if (Test-Path $pkgJson) {
    $pkg = Get-Content $pkgJson | ConvertFrom-Json
    if ($pkg.dependencies) {
        $pkg.dependencies.PSObject.Properties | ForEach-Object {
            $detected.Add("  - $($_.Name): $($_.Value)")
        }
    }
    if ($pkg.devDependencies) {
        $pkg.devDependencies.PSObject.Properties | ForEach-Object {
            $detected.Add("  - $($_.Name) (dev): $($_.Value)")
        }
    }
}

# Python
$pyVer = & python --version 2>&1; if ($LASTEXITCODE -eq 0) { $detected.Add("  - Python: $pyVer") }
$reqFile = Join-Path $ROOT "requirements.txt"
if (Test-Path $reqFile) {
    Get-Content $reqFile | Where-Object { $_ -match '\S' -and $_ -notmatch '^#' } | ForEach-Object {
        $detected.Add("  - $_")
    }
}

# Go
$goVer = & go version 2>$null; if ($LASTEXITCODE -eq 0) { $detected.Add("  - Go: $goVer") }

# Docker / Compose
$dockerVer = & docker --version 2>$null; if ($LASTEXITCODE -eq 0) { $detected.Add("  - Docker: $dockerVer") }

if ($detected.Count -eq 0) { $detected.Add("  - (no managed dependencies detected)") }

# --- 4. Write updated 02-stack.md ---
$timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$libraryBlock = $detected -join "`n"

$newContent = @"
# 02-stack.md

<metadata>
  <last_sync>$timestamp</last_sync>
  <stack_hash>$newHash</stack_hash>
</metadata>

## Active Stack Manifest

$libraryBlock
"@

Set-Content -Path $STACK_FILE -Value $newContent -Encoding UTF8
Write-Host "[stack-sync] Stack manifest updated. Hash: $($newHash.Substring(0,12))..." -ForegroundColor Green
Write-Host "[stack-sync] Manifests scanned: $($manifestFiles.Count)" -ForegroundColor Gray
