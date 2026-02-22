param(
  [string]$Branch = 'main',
  [switch]$Quiet
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Invoke-Git {
  param([string[]]$Args)
  & git @Args
  if ($LASTEXITCODE -ne 0) {
    throw "git command failed: git $($Args -join ' ')"
  }
}

function Get-GitOutput {
  param([string[]]$Args)
  $output = & git @Args
  if ($LASTEXITCODE -ne 0) {
    throw "git command failed: git $($Args -join ' ')"
  }
  return (($output -join "`n").Trim())
}

function Write-Info {
  param([string]$Message)
  if (-not $Quiet) {
    Write-Host $Message
  }
}

$repoRoot = Get-GitOutput @('rev-parse', '--show-toplevel')
if (-not $repoRoot) {
  throw 'Not inside a git repository.'
}

Push-Location $repoRoot
try {
  $dirty = Get-GitOutput @('status', '--porcelain')
  if ($dirty) {
    throw 'Local changes detected. Commit/stash/revert local changes first.'
  }

  Write-Info "[sync] fetch origin/$Branch"
  Invoke-Git @('fetch', 'origin', $Branch, '--prune')

  $before = Get-GitOutput @('rev-parse', '--short', 'HEAD')
  Invoke-Git @('pull', '--ff-only', 'origin', $Branch)
  $after = Get-GitOutput @('rev-parse', '--short', 'HEAD')

  if ($before -eq $after) {
    Write-Info "[sync] up to date ($after)"
  } else {
    Write-Info "[sync] updated: $before -> $after"
  }
}
finally {
  Pop-Location
}
