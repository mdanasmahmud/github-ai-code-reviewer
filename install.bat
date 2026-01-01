@echo off
title PR-Agent One-Click Installer
color 0A

echo.
echo  ============================================================
echo                    PR-AGENT INSTALLER
echo           One-Click Setup for Windows + Ollama
echo           Local AI Code Review for GitHub PRs
echo  ============================================================
echo.

REM Check if running as admin
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [WARNING] Not running as Administrator. Some features may not work.
    echo [INFO] Right-click and "Run as Administrator" for best results.
    echo.
)

echo [STEP 1/5] Checking prerequisites...
echo.

REM Check if winget is available
where winget >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] winget is not installed. Please install App Installer from Microsoft Store.
    pause
    exit /b 1
)
echo   [OK] winget found

REM Check if git is available
where git >nul 2>&1
if %errorLevel% neq 0 (
    echo   [INSTALLING] Git not found. Installing...
    winget install Git.Git --accept-package-agreements --accept-source-agreements
)
echo   [OK] Git found

REM Check if Python is available
where python >nul 2>&1
if %errorLevel% neq 0 (
    echo   [INSTALLING] Python not found. Installing...
    winget install Python.Python.3.11 --accept-package-agreements --accept-source-agreements
)
echo   [OK] Python found

echo.
echo [STEP 2/5] Installing Ollama...
echo.

REM Check if Ollama is installed
where ollama >nul 2>&1
if %errorLevel% neq 0 (
    echo   [INSTALLING] Ollama...
    winget install Ollama.Ollama --accept-package-agreements --accept-source-agreements
    echo   [INFO] Please restart this script after Ollama installation completes.
    pause
    exit /b 0
)
echo   [OK] Ollama already installed

echo.
echo [STEP 3/5] Downloading AI Model (qwen2.5-coder:7b ~4.7GB)...
echo   This may take several minutes depending on your internet speed.
echo.

ollama pull qwen2.5-coder:7b

echo.
echo [STEP 4/5] Installing PR-Agent Python package...
echo.

pip install pr-agent

echo.
echo [STEP 5/5] Configuration...
echo.

set /p INSTALL_PATH="Enter installation path (default: C:\pr-agent-runner): "
if "%INSTALL_PATH%"=="" set INSTALL_PATH=C:\pr-agent-runner

set /p REPO_URL="Enter your GitHub repository URL (e.g., https://github.com/username/repo): "
if "%REPO_URL%"=="" (
    echo [ERROR] Repository URL is required!
    pause
    exit /b 1
)

echo.
echo ============================================================
echo  IMPORTANT: You need to get a Runner Token from GitHub
echo ============================================================
echo.
echo  1. Go to: %REPO_URL%/settings/actions/runners/new
echo  2. Select "Windows" and "x64"
echo  3. Copy the token from the configuration command
echo.
echo ============================================================
echo.

set /p RUNNER_TOKEN="Paste your GitHub Runner Token here: "
if "%RUNNER_TOKEN%"=="" (
    echo [ERROR] Runner token is required!
    pause
    exit /b 1
)

set /p RUNNER_NAME="Enter a name for this runner (default: pr-agent-runner): "
if "%RUNNER_NAME%"=="" set RUNNER_NAME=pr-agent-runner

echo.
echo [INFO] Setting up runner at %INSTALL_PATH%...
echo.

REM Create installation directory
if not exist "%INSTALL_PATH%" mkdir "%INSTALL_PATH%"
cd /d "%INSTALL_PATH%"

REM Download runner
echo [INFO] Downloading GitHub Actions Runner...
powershell -Command "Invoke-WebRequest -Uri 'https://github.com/actions/runner/releases/download/v2.330.0/actions-runner-win-x64-2.330.0.zip' -OutFile 'runner.zip'"

echo [INFO] Extracting runner...
powershell -Command "Expand-Archive -Path 'runner.zip' -DestinationPath '.' -Force"

echo [INFO] Configuring runner...
.\config.cmd --url %REPO_URL% --token %RUNNER_TOKEN% --name %RUNNER_NAME% --labels self-hosted,windows,ollama --unattended

REM Set environment variable for Ollama context
setx OLLAMA_CONTEXT_LENGTH 32768

REM Copy workflow file
echo [INFO] Copying workflow file...
xcopy "%~dp0workflow\pr_agent.yml" "%INSTALL_PATH%\" /Y

echo.
echo ============================================================
echo  INSTALLATION COMPLETE!
echo ============================================================
echo.
echo  Runner installed at: %INSTALL_PATH%
echo  Runner name: %RUNNER_NAME%
echo  Repository: %REPO_URL%
echo.
echo  NEXT STEPS:
echo.
echo  1. Copy the workflow file to your repository:
echo     - Copy '%INSTALL_PATH%\pr_agent.yml' 
echo     - To your repo at '.github\workflows\pr_agent.yml'
echo.
echo  2. Start the runner:
echo     cd "%INSTALL_PATH%"
echo     .\run.cmd
echo.
echo  3. Create a Pull Request to test!
echo.
echo ============================================================
echo.

set /p START_RUNNER="Start the runner now? (Y/N): "
if /i "%START_RUNNER%"=="Y" (
    echo [INFO] Starting runner...
    start "PR-Agent Runner" cmd /k "cd /d %INSTALL_PATH% && run.cmd"
)

echo.
echo Thank you for using PR-Agent Installer!
echo.
pause
