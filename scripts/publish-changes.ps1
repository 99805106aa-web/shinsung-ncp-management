param(
  [string]$Message = '',
  [string]$Branch = 'main',
  [switch]$AllFiles,
  [string[]]$Files = @(
    'index.html',
    '신성텍_부적합보고서.html',
    'data_export.json',
    'cloud/uploaded_report_cache.json'
  )
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

$repoRoot = Get-GitOutput @('rev-parse', '--show-toplevel')
if (-not $repoRoot) {
  throw 'Not inside a git repository.'
}

Push-Location $repoRoot
try {
  Invoke-Git @('fetch', 'origin', $Branch, '--prune')

  if ($AllFiles) {
    Invoke-Git @('add', '-A')
  } else {
    $existing = @()
    foreach ($f in $Files) {
      if (Test-Path -LiteralPath (Join-Path $repoRoot $f)) {
        $existing += $f
      }
    }
    if ($existing.Count -eq 0) {
      throw 'No target files found to stage.'
    }
    $addArgs = @('add', '--') + $existing
    Invoke-Git $addArgs
  }

  $staged = Get-GitOutput @('diff', '--cached', '--name-only')
  if (-not $staged) {
    Write-Host '[publish] nothing to commit.'
    exit 0
  }

  if (-not $Message) {
    $stamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $Message = "publish html update $stamp"
  }

  Invoke-Git @('commit', '-m', $Message)
  Invoke-Git @('push', 'origin', $Branch)

  $head = Get-GitOutput @('rev-parse', '--short', 'HEAD')
  Write-Host "[publish] done: $head"
}
finally {
  Pop-Location
}
