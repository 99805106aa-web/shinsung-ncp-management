param(
  [int]$Port = 8787,
  [string]$RootPath = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ($Port -lt 1 -or $Port -gt 65535) {
  throw 'Port must be between 1 and 65535.'
}

if (-not $RootPath) {
  $RootPath = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
}

if (-not (Test-Path -LiteralPath $RootPath)) {
  throw "Root path not found: $RootPath"
}

$startBatch = Join-Path $RootPath 'start-local-server.bat'
if (-not (Test-Path -LiteralPath $startBatch)) {
  throw "Missing batch file: $startBatch"
}

$startupDir = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Startup'
if (-not (Test-Path -LiteralPath $startupDir)) {
  throw "Startup folder not found: $startupDir"
}

$launcherPath = Join-Path $startupDir 'Shinsung-NCP-LocalServer-AutoStart.vbs'
$batEscaped = $startBatch.Replace('"', '""')
$vbs = @"
Set WshShell = CreateObject("WScript.Shell")
WshShell.Run """" & "$batEscaped" & """", 0, False
"@

Set-Content -LiteralPath $launcherPath -Value $vbs -Encoding Unicode

# 즉시 한 번 실행
& wscript.exe "$launcherPath"

Write-Host "Autostart launcher created: $launcherPath"
Write-Host "Trigger : At Windows logon (current user)"
Write-Host "Server  : http://127.0.0.1:$Port/index.html"
