param(
  [int]$Port = 8787,
  [string]$BindHost = '0.0.0.0',
  [string]$RootPath = '',
  [switch]$OpenBrowser,
  [switch]$AllowPublicClients
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

$pythonCmd = Get-Command python -ErrorAction SilentlyContinue
if (-not $pythonCmd) {
  throw 'python is required. Please install Python or use another local web server.'
}

$serverScript = Join-Path $PSScriptRoot 'start-local-server.py'
if (-not (Test-Path -LiteralPath $serverScript)) {
  throw "Server script not found: $serverScript"
}

Write-Host 'Stopping previous local server instances (if any)...'
Get-CimInstance Win32_Process |
  Where-Object {
    $_.Name -match '^python(\.exe)?$' -and
    ($_.CommandLine -match 'start-local-server\.py')
  } |
  ForEach-Object {
    try { Stop-Process -Id $_.ProcessId -Force -ErrorAction Stop } catch {}
  }

$url = "http://$BindHost`:$Port/index.html"
Write-Host "Serving: $RootPath"
Write-Host "URL    : $url"
Write-Host 'Stop   : Ctrl+C'

if ($OpenBrowser) {
  Start-Process $url | Out-Null
}

$args = @(
  $serverScript,
  '--host', $BindHost,
  '--port', $Port,
  '--root', $RootPath
)
if ($AllowPublicClients) {
  $args += '--allow-public-clients'
}

& $pythonCmd.Source @args
