@echo off
setlocal enableextensions

set "SCRIPT_DIR=%~dp0"
set "ROOT_PATH=%SCRIPT_DIR%"
if "%ROOT_PATH:~-1%"=="\" set "ROOT_PATH=%ROOT_PATH:~0,-1%"
set "PY_CMD="

where py >nul 2>nul
if %ERRORLEVEL%==0 (
  set "PY_CMD=py -3"
)

if not defined PY_CMD (
  where python >nul 2>nul
  if %ERRORLEVEL%==0 (
    set "PY_CMD=python"
  )
)

if not defined PY_CMD (
  echo [ERROR] Python not found. Install Python and retry.
  pause
  endlocal & exit /b 1
)

echo [INFO] Stopping previous local server instances (if any)...
for /f "tokens=2 delims== " %%P in ('wmic process where "name='python.exe' and commandline like '%%start-local-server.py%%'" get processid /value ^| find "ProcessId="') do (
  taskkill /F /PID %%P >nul 2>nul
)
for /f "tokens=2 delims== " %%P in ('wmic process where "name='py.exe' and commandline like '%%start-local-server.py%%'" get processid /value ^| find "ProcessId="') do (
  taskkill /F /PID %%P >nul 2>nul
)
echo [INFO] Freeing TCP 8787 if still in LISTENING state...
for /f "tokens=5" %%P in ('netstat -ano 2^>nul ^| findstr ":8787" ^| findstr "LISTENING"') do (
  echo [INFO] Ending PID %%P holding port 8787...
  taskkill /F /PID %%P >nul 2>nul
)

echo [INFO] Checking firewall rule for TCP 8787...
netsh advfirewall firewall show rule name="ShinsungQC_Port8787" >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
  netsh advfirewall firewall add rule name="ShinsungQC_Port8787" dir=in action=allow protocol=TCP localport=8787 >nul 2>nul
  if %ERRORLEVEL%==0 (
    echo [INFO] Firewall rule created: ShinsungQC_Port8787
  ) else (
    echo [WARN] Could not add firewall rule automatically.
    echo [WARN] If other devices cannot connect, allow TCP 8787 inbound manually.
  )
) else (
  echo [INFO] Firewall rule already exists.
)

echo.
echo Starting local server (preferred port 8787)...
echo If 8787 is busy, Python will pick the next free port and print the real URL below.
echo.
%PY_CMD% "%SCRIPT_DIR%scripts\start-local-server.py" --host 0.0.0.0 --port 8787 --root "%ROOT_PATH%" --allow-public-clients
set "RC=%ERRORLEVEL%"

if not "%RC%"=="0" (
  echo.
  echo [ERROR] Local server failed. Press any key to close.
  pause
)

endlocal & exit /b %RC%
