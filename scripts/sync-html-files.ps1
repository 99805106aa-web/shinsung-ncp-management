param(
  [string]$RootPath = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not $RootPath) {
  $RootPath = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
}

$indexPath = Join-Path $RootPath 'index.html'
$altCandidates = @(Get-ChildItem -LiteralPath $RootPath -File -Filter '*.html' | Where-Object { $_.Name -ne 'index.html' })

if (-not (Test-Path -LiteralPath $indexPath)) {
  throw "Missing file: $indexPath"
}
if (-not $altCandidates -or $altCandidates.Count -eq 0) {
  throw 'Missing file: alternate html not found (except index.html).'
}

$indexInfo = Get-Item -LiteralPath $indexPath
$altInfo = $altCandidates | Sort-Object Name | Select-Object -First 1
$altPath = $altInfo.FullName

if ($indexInfo.LastWriteTimeUtc -ge $altInfo.LastWriteTimeUtc) {
  Copy-Item -LiteralPath $indexPath -Destination $altPath -Force
  Write-Host "[sync-html] index.html -> $($altInfo.Name)"
} else {
  Copy-Item -LiteralPath $altPath -Destination $indexPath -Force
  Write-Host "[sync-html] $($altInfo.Name) -> index.html"
}
