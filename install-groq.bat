@echo off
title PR-Agent Installer (Groq Cloud Version)
color 0B

echo.
echo  ============================================================
echo          PR-AGENT INSTALLER (GROQ CLOUD VERSION)
echo           No GPU Required - Works on Any Server!
echo  ============================================================
echo.

REM Check if running as admin
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [WARNING] Not running as Administrator. Some features may not work.
    echo.
)

echo [STEP 1/4] Checking prerequisites...
echo.

REM Check if winget is available (Windows only)
where winget >nul 2>&1
if %errorLevel% neq 0 (
    echo [INFO] winget not found. Will try alternative installation methods.
)

REM Check if git is available
where git >nul 2>&1
if %errorLevel% neq 0 (
    echo   [INSTALLING] Git not found. Installing...
    winget install Git.Git --accept-package-agreements --accept-source-agreements 2>nul
    if %errorLevel% neq 0 (
        echo   [ERROR] Please install Git manually from https://git-scm.com
        pause
        exit /b 1
    )
)
echo   [OK] Git found

REM Check if Python is available
where python >nul 2>&1
if %errorLevel% neq 0 (
    echo   [INSTALLING] Python not found. Installing...
    winget install Python.Python.3.11 --accept-package-agreements --accept-source-agreements 2>nul
    if %errorLevel% neq 0 (
        echo   [ERROR] Please install Python manually from https://python.org
        pause
        exit /b 1
    )
)
echo   [OK] Python found

echo.
echo [STEP 2/4] Installing PR-Agent...
echo.

pip install pr-agent

echo.
echo [STEP 3/4] Configuration...
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
echo  GROQ API KEY
echo ============================================================
echo.
echo  Get your FREE API key from: https://console.groq.com/keys
echo.
echo ============================================================
echo.

set /p GROQ_KEY="Enter your Groq API Key: "
if "%GROQ_KEY%"=="" (
    echo [ERROR] Groq API key is required!
    pause
    exit /b 1
)

echo.
echo ============================================================
echo  GITHUB RUNNER TOKEN
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

set /p RUNNER_NAME="Enter a name for this runner (default: pr-agent-groq): "
if "%RUNNER_NAME%"=="" set RUNNER_NAME=pr-agent-groq

echo.
echo [STEP 4/4] Setting up runner at %INSTALL_PATH%...
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
.\config.cmd --url %REPO_URL% --token %RUNNER_TOKEN% --name %RUNNER_NAME% --labels self-hosted,windows --unattended

REM Save Groq API key info
echo [INFO] Saving configuration...
echo GROQ_API_KEY=%GROQ_KEY%> "%INSTALL_PATH%\.env"
echo.
echo [IMPORTANT] Your Groq API key has been saved to %INSTALL_PATH%\.env
echo             You must also add it as a GitHub Secret!

REM Copy workflow file
echo [INFO] Workflow file ready...
xcopy "%~dp0workflow-groq\pr_agent.yml" "%INSTALL_PATH%\" /Y

echo.
echo ============================================================
echo  INSTALLATION COMPLETE!
echo ============================================================
echo.
echo  Runner installed at: %INSTALL_PATH%
echo  Runner name: %RUNNER_NAME%
echo  Using: Groq Cloud API (FREE!)
echo.
echo  IMPORTANT - Add GitHub Secret:
echo  1. Go to: %REPO_URL%/settings/secrets/actions
echo  2. Click "New repository secret"
echo  3. Name: GROQ_API_KEY
echo  4. Value: %GROQ_KEY%
echo.
echo  NEXT STEPS:
echo  1. Add the GitHub Secret (GROQ_API_KEY)
echo  2. Copy '%INSTALL_PATH%\pr_agent.yml' to '.github\workflows\'
echo  3. Start the runner: cd "%INSTALL_PATH%" ^&^& .\run.cmd
echo  4. Create a Pull Request to test!
echo.
echo ============================================================
echo.

set /p START_RUNNER="Start the runner now? (Y/N): "
if /i "%START_RUNNER%"=="Y" (
    echo [INFO] Starting runner...
    start "PR-Agent Runner (Groq)" cmd /k "cd /d %INSTALL_PATH% && run.cmd"
)

echo.
echo Thank you for using PR-Agent Installer!
echo.
pause
