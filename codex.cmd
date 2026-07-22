@echo off
setlocal EnableExtensions DisableDelayedExpansion

rem Run Codex from plain CMD, even if codex.exe is not on PATH.
for /f "tokens=2 delims=:." %%A in ('chcp') do set "_OLD_CP=%%A"
set "_OLD_CP=%_OLD_CP: =%"
chcp 65001 >nul

set "_CODEX_EXE="

for /f "delims=" %%I in ('where.exe codex.exe 2^>nul') do (
  if not defined _CODEX_EXE set "_CODEX_EXE=%%~fI"
)

if not defined _CODEX_EXE (
  set "_EXT_GLOB=%USERPROFILE%\.vscode\extensions\openai.chatgpt-*\bin\windows-x86_64\codex.exe"
  for /f "delims=" %%I in ('dir /b /s "%_EXT_GLOB%" 2^>nul ^| sort /r') do (
    set "_CODEX_EXE=%%~fI"
    goto :run_codex
  )
)

:run_codex
if defined _CODEX_EXE (
  "%_CODEX_EXE%" %*
  set "RC=%ERRORLEVEL%"
  goto :done
)

echo [ERROR] Could not find codex.exe.
echo [HINT] Install/update the ChatGPT VS Code extension, then retry.
set "RC=1"

:done
if defined _OLD_CP chcp %_OLD_CP% >nul
endlocal & exit /b %RC%
