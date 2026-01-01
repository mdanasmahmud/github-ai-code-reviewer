@echo off
title PR-Agent Runner
echo Starting PR-Agent Runner...
echo.

REM Try to find the runner installation
if exist "C:\pr-agent-runner\run.cmd" (
    cd /d C:\pr-agent-runner
    .\run.cmd
) else (
    echo [ERROR] Runner not found at C:\pr-agent-runner
    echo.
    set /p CUSTOM_PATH="Enter your runner installation path: "
    if exist "%CUSTOM_PATH%\run.cmd" (
        cd /d %CUSTOM_PATH%
        .\run.cmd
    ) else (
        echo [ERROR] Runner not found at %CUSTOM_PATH%
        echo Please run install.bat first.
        pause
    )
)
