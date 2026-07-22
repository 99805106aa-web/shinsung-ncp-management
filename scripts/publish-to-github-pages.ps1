# Publish this folder to GitHub Pages (main branch)
# Usage:
#   powershell -ExecutionPolicy Bypass -File .\scripts\publish-to-github-pages.ps1
# Optional:
#   -RepoUrl "https://github.com/99805106aa-web/shinsung-ncp-management.git"
#   -SkipPush   (commit only)

param(
  [string]$RepoUrl = "https://github.com/99805106aa-web/shinsung-ncp-management.git",
  [string]$Branch = "main",
  [switch]$SkipPush
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path (Join-Path $Root "index.html"))) {
  throw "index.html not found in $Root"
}

$Work = Join-Path $env:TEMP ("shinsung-ncp-pages-" + [guid]::NewGuid().ToString("N").Substring(0, 8))
Write-Host "[1/5] Clone $RepoUrl → $Work"
git clone --depth 1 --branch $Branch $RepoUrl $Work
if ($LASTEXITCODE -ne 0) { throw "git clone failed" }

Write-Host "[2/5] Sync files from local workspace"
$exclude = @(
  ".git", "_tmp_export_test", "_tmp_diff.txt", "_bat_all_output.txt", "_bat_stdout.txt",
  "server-err.log", "cloud\sw_attachments", "agent-transcripts"
)
$robolog = Join-Path $env:TEMP "shinsung-robo.log"
$xd = @()
foreach ($e in $exclude) {
  if ($e -notmatch '\\') { $xd += $e }
}
# /E copy subdirs, /NFL /NDL quieter
$args = @(
  $Root, $Work, "/E", "/XD", ".git", "_tmp_export_test", "cloud\sw_attachments",
  "/XF", "server-err.log", "_tmp_diff.txt", "_bat_all_output.txt", "_bat_stdout.txt",
  "/R:1", "/W:1", "/NFL", "/NDL", "/NJH", "/NJS"
)
& robocopy @args | Out-Null
# robocopy exit codes 0-7 are success-ish
if ($LASTEXITCODE -ge 8) { throw "robocopy failed with code $LASTEXITCODE" }

# Ensure Pages helpers exist
New-Item -ItemType File -Path (Join-Path $Work ".nojekyll") -Force | Out-Null

Set-Location $Work
Write-Host "[3/5] git add"
git add -A
$status = git status --porcelain
if (-not $status) {
  Write-Host "No changes to publish."
  Set-Location $Root
  Remove-Item -Recurse -Force $Work -ErrorAction SilentlyContinue
  exit 0
}

Write-Host "[4/5] commit"
$msg = "Publish mobile GitHub Pages build $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
git -c user.email="ncp-publisher@local" -c user.name="NCP Publisher" commit -m $msg
if ($LASTEXITCODE -ne 0) { throw "git commit failed" }

if (-not $SkipPush) {
  Write-Host "[5/5] push origin $Branch"
  git push origin $Branch
  if ($LASTEXITCODE -ne 0) { throw "git push failed — GitHub 로그인/권한이 필요합니다." }
  Write-Host ""
  Write-Host "Done. Open on phone:"
  Write-Host "  https://99805106aa-web.github.io/shinsung-ncp-management/"
  Write-Host "(반영까지 1~2분 소요될 수 있습니다)"
} else {
  Write-Host "[5/5] SkipPush — commit only at $Work"
}

Set-Location $Root
