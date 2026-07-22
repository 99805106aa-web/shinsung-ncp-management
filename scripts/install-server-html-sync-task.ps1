param(
  [string]$TaskName = 'Shinsung-NCP-HtmlSync',
  [int]$Minutes = 1,
  [string]$RootPath = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ($Minutes -lt 1) {
  throw 'Minutes must be 1 or greater.'
}

if (-not $RootPath) {
  $RootPath = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
}

$syncScript = Join-Path $PSScriptRoot 'sync-html-files.ps1'
if (-not (Test-Path -LiteralPath $syncScript)) {
  throw "Missing script: $syncScript"
}

$psExe = (Get-Command powershell.exe).Source
$taskRun = "`"$psExe`" -NoProfile -ExecutionPolicy Bypass -File `"$syncScript`" -RootPath `"$RootPath`""

& schtasks.exe /Create /TN $TaskName /SC MINUTE /MO $Minutes /TR $taskRun /F
if ($LASTEXITCODE -ne 0) {
  throw 'Failed to create scheduled task.'
}

& schtasks.exe /Run /TN $TaskName | Out-Null

Write-Host "Scheduled task created: $TaskName"
Write-Host "Sync every $Minutes minute(s)"
