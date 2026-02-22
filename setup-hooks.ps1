Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
git -C $repoRoot config core.hooksPath .githooks | Out-Null

Write-Host 'core.hooksPath=.githooks configured'
Write-Host 'On commit, 신성텍_부적합보고서.html -> index.html will be auto-synced.'
