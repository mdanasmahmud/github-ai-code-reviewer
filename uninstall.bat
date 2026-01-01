@echo off
title Uninstall PR-Agent
color 0C

echo.
echo  ============================================================
echo               PR-AGENT UNINSTALLER
echo  ============================================================
echo.
echo  This will remove the GitHub Actions Runner configuration.
echo  (Ollama and models will NOT be removed)
echo.

set /p CONFIRM="Are you sure you want to uninstall? (Y/N): "
if /i not "%CONFIRM%"=="Y" (
    echo Uninstall cancelled.
    pause
    exit /b 0
)

set /p INSTALL_PATH="Enter runner installation path (default: C:\pr-agent-runner): "
if "%INSTALL_PATH%"=="" set INSTALL_PATH=C:\pr-agent-runner

echo.
echo [INFO] Stopping runner service...
cd /d "%INSTALL_PATH%"
.\svc.cmd stop 2>nul
.\svc.cmd uninstall 2>nul

echo [INFO] Removing runner configuration...
set /p TOKEN="Enter a GitHub token to remove the runner (or press Enter to skip): "
if not "%TOKEN%"=="" (
    .\config.cmd remove --token %TOKEN%
)

echo.
echo [INFO] Removing files...
set /p DELETE_FILES="Delete the runner folder? (Y/N): "
if /i "%DELETE_FILES%"=="Y" (
    cd /d C:\
    rmdir /s /q "%INSTALL_PATH%"
    echo   [OK] Folder deleted
)

echo.
echo  ============================================================
echo  UNINSTALL COMPLETE
echo  ============================================================
echo.
echo  Note: Ollama and the AI model are still installed.
echo  To remove them:
echo    winget uninstall Ollama.Ollama
echo    pip uninstall pr-agent
echo.
pause
