Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
git -C $repoRoot config core.hooksPath .githooks | Out-Null

Write-Host 'core.hooksPath=.githooks configured'
Write-Host 'On commit, non-index html -> index.html will be auto-synced.'
