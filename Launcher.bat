@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "LAUNCHER=%SCRIPT_DIR%Launcher.ps1"

where pwsh >nul 2>&1
if errorlevel 1 (
    echo.
    echo WRTE requires PowerShell 7 or later.
    echo PowerShell 7 ^(pwsh.exe^) was not found in PATH.
    echo.
    pause
    exit /b 1
)

if not exist "%LAUNCHER%" (
    echo.
    echo WRTE failed to start.
    echo Launcher.ps1 was not found:
    echo %LAUNCHER%
    echo.
    pause
    exit /b 1
)

pwsh -NoProfile -ExecutionPolicy Bypass -File "%LAUNCHER%"

if errorlevel 1 (
    echo.
    echo WRTE exited with an error.
    echo.
    pause
)

endlocal