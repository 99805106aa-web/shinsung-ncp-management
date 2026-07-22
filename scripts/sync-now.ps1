param(
  [string]$ServerPath = '',
  [string]$LocalRepoPath = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not $LocalRepoPath) {
  $LocalRepoPath = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
}

if (-not $ServerPath) {
  $ServerPath = $env:SHINSUNG_SERVER_PATH
}

if (-not $ServerPath) {
  throw 'ServerPath is required. Use -ServerPath or set env SHINSUNG_SERVER_PATH.'
}

$syncScript = Join-Path $PSScriptRoot 'sync-from-server.ps1'
if (-not (Test-Path -LiteralPath $syncScript)) {
  throw "Missing script: $syncScript"
}

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $syncScript -SourcePath $ServerPath -TargetPath $LocalRepoPath
if ($LASTEXITCODE -ne 0) {
  throw "Sync failed with exit code: $LASTEXITCODE"
}
