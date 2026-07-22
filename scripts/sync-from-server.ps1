param(
  [string]$SourcePath = '',
  [string]$TargetPath = '',
  [switch]$Quiet
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Info {
  param([string]$Message)
  if (-not $Quiet) {
    Write-Host $Message
  }
}

if (-not $TargetPath) {
  $TargetPath = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
}

if (-not $SourcePath) {
  $SourcePath = $env:SHINSUNG_SERVER_PATH
}

if (-not $SourcePath) {
  throw 'SourcePath is required. Use -SourcePath or set env SHINSUNG_SERVER_PATH.'
}

if (-not (Test-Path -LiteralPath $SourcePath)) {
  throw "Source path not found: $SourcePath"
}

if (-not (Test-Path -LiteralPath $TargetPath)) {
  New-Item -ItemType Directory -Path $TargetPath -Force | Out-Null
}

$sourceResolved = (Resolve-Path -LiteralPath $SourcePath).Path
$targetResolved = (Resolve-Path -LiteralPath $TargetPath).Path

if ($sourceResolved.TrimEnd('\') -ieq $targetResolved.TrimEnd('\')) {
  throw 'SourcePath and TargetPath are the same. Set TargetPath to a local client folder.'
}

Write-Info "[sync] source: $sourceResolved"
Write-Info "[sync] target: $targetResolved"

$args = @(
  $sourceResolved,
  $targetResolved,
  '/E',
  '/XO',
  '/FFT',
  '/Z',
  '/R:2',
  '/W:2',
  '/NP',
  '/XD', '.git',
  '/XF', 'uploaded_report_cache.json'
)

if ($Quiet) {
  & robocopy @args | Out-Null
} else {
  & robocopy @args
}

$exitCode = $LASTEXITCODE
if ($exitCode -gt 7) {
  throw "robocopy failed (exit code: $exitCode)"
}

Write-Info "[sync] done (robocopy exit code: $exitCode)"
