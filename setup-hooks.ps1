Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
git -C $repoRoot config core.hooksPath .githooks

Write-Host "core.hooksPath = .githooks 설정 완료"
Write-Host "이제 커밋 시 '신성텍_부적합보고서.html' -> 'index.html' 자동 동기화가 실행됩니다."
