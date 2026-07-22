param(
  [string]$ServerPath = '',
  [string]$LocalRepoPath = '',
  [string]$TaskName = 'Shinsung-NCP-ServerSync',
  [int]$Minutes = 3
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ($Minutes -lt 1) {
  throw 'Minutes must be 1 or greater.'
}

if (-not $LocalRepoPath) {
  $LocalRepoPath = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
}

if (-not $ServerPath) {
  $ServerPath = $env:SHINSUNG_SERVER_PATH
}

if (-not $ServerPath) {
  throw 'ServerPath is required. Use -ServerPath or set env SHINSUNG_SERVER_PATH.'
}

if (-not (Test-Path -LiteralPath $ServerPath)) {
  throw "Server path not found: $ServerPath"
}

if (-not (Test-Path -LiteralPath $LocalRepoPath)) {
  throw "Local repo path not found: $LocalRepoPath"
}

$syncScript = Join-Path $LocalRepoPath 'scripts\sync-from-server.ps1'
if (-not (Test-Path -LiteralPath $syncScript)) {
  throw "Missing sync script: $syncScript"
}

$psExe = (Get-Command powershell.exe).Source
$taskRun = "`"$psExe`" -NoProfile -ExecutionPolicy Bypass -File `"$syncScript`" -SourcePath `"$ServerPath`" -TargetPath `"$LocalRepoPath`" -Quiet"

& schtasks.exe /Create /TN $TaskName /SC MINUTE /MO $Minutes /TR $taskRun /F
if ($LASTEXITCODE -ne 0) {
  throw 'Failed to create scheduled task.'
}

& schtasks.exe /Run /TN $TaskName | Out-Null
if ($LASTEXITCODE -ne 0) {
  Write-Warning "Task created but failed to run immediately: $TaskName"
}

Write-Host "Scheduled task created: $TaskName"
Write-Host "Sync every $Minutes minute(s)"
Write-Host "Server: $ServerPath"
Write-Host "Local : $LocalRepoPath"
