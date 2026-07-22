param(
  [string]$TaskName = 'Shinsung-NCP-ServerSync'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

& schtasks.exe /Delete /TN $TaskName /F
if ($LASTEXITCODE -ne 0) {
  throw "Failed to remove scheduled task: $TaskName"
}

Write-Host "Scheduled task removed: $TaskName"
