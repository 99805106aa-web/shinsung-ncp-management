param(
  [string]$TaskName = 'Shinsung-NCP-AutoSync'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

& schtasks.exe /Delete /TN $TaskName /F
if ($LASTEXITCODE -ne 0) {
  throw 'Failed to remove scheduled task.'
}

Write-Host "Scheduled task removed: $TaskName"
