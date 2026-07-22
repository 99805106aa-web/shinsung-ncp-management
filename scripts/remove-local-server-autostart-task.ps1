param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$startupDir = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Startup'
$launcherPath = Join-Path $startupDir 'Shinsung-NCP-LocalServer-AutoStart.vbs'

if (Test-Path -LiteralPath $launcherPath) {
  Remove-Item -LiteralPath $launcherPath -Force
  Write-Host "Autostart launcher removed: $launcherPath"
} else {
  Write-Host "Autostart launcher not found: $launcherPath"
}

# 과거 예약작업 방식 잔여가 있으면 정리 시도 (없으면 무시)
& schtasks.exe /Delete /TN "Shinsung-NCP-LocalServer-AutoStart" /F 2>$null | Out-Null
