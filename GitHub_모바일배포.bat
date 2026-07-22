@echo off
setlocal
cd /d "%~dp0"
echo Publishing to GitHub Pages...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\publish-to-github-pages.ps1"
set RC=%ERRORLEVEL%
if not "%RC%"=="0" (
  echo.
  echo [ERROR] Publish failed. GitHub 인증이 필요할 수 있습니다.
  echo 브라우저에서 https://github.com/login 로그인 후 Git Credential Manager로 다시 시도하세요.
  pause
)
endlocal & exit /b %RC%
