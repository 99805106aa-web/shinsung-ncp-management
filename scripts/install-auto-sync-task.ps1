param(
  [string]$TaskName = 'Shinsung-NCP-AutoSync',
  [int]$Minutes = 3,
  [string]$Branch = 'main'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ($Minutes -lt 1) {
  throw 'Minutes must be 1 or greater.'
}

$repoRoot = (& git rev-parse --show-toplevel).Trim()
if ($LASTEXITCODE -ne 0 -or -not $repoRoot) {
  throw 'Not inside a git repository.'
}

$syncScript = Join-Path $repoRoot 'scripts/sync-latest.ps1'
if (-not (Test-Path -LiteralPath $syncScript)) {
  throw "Missing file: $syncScript"
}

$psExe = (Get-Command powershell.exe).Source
$taskRun = "`"$psExe`" -NoProfile -ExecutionPolicy Bypass -File `"$syncScript`" -Branch `"$Branch`" -Quiet"

& schtasks.exe /Create /TN $TaskName /SC MINUTE /MO $Minutes /TR $taskRun /F
if ($LASTEXITCODE -ne 0) {
  throw 'Failed to create scheduled task.'
}

Write-Host "Scheduled task created: $TaskName"
Write-Host "Interval: every $Minutes minute(s)"
Write-Host 'You can remove it with scripts/remove-auto-sync-task.ps1'
