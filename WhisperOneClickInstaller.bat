@echo off
:: =================================================================================
:: Whisper One-Click Installer for Windows
:: =================================================================================
:: This script automates the entire installation process for OpenAI's Whisper
:: and all its dependencies, including Chocolatey, Python, FFmpeg, and PyTorch.
::
:: How to use:
:: 1. Save this file as "install_whisper.bat".
:: 2. Right-click the file and select "Run as administrator".
:: =================================================================================

:: ---------------------------------------------------------------------------------
:: 1. CHECK FOR ADMINISTRATOR PRIVILEGES
:: ---------------------------------------------------------------------------------
fsutil dirty query %systemdrive% >nul
if %errorlevel% neq 0 (
    echo Requesting administrator permissions...
    powershell -Command "Start-Process '%0' -Verb RunAs"
    exit /b
)

echo.
echo ===================================================
echo  Whisper Installer - Running as Administrator
echo ===================================================
echo.
echo This script will now install all necessary components.
echo Please do not close this window. The process may take some time.
echo.
pause


:: ---------------------------------------------------------------------------------
:: 2. INSTALL CHOCOLATEY (if not already installed)
:: ---------------------------------------------------------------------------------
echo.
echo [STEP 1/5] Checking for Chocolatey package manager...
where choco >nul 2>nul
if %errorlevel% neq 0 (
    echo Chocolatey not found. Installing now...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
    if %errorlevel% neq 0 (
        echo ERROR: Failed to install Chocolatey. Please try running the script again.
        pause
        exit /b
    )
    echo Chocolatey installed successfully.
) else (
    echo Chocolatey is already installed.
)


:: ---------------------------------------------------------------------------------
:: 3. INSTALL PYTHON & FFMPEG using Chocolatey
:: ---------------------------------------------------------------------------------
echo.
echo [STEP 2/5] Installing Python and FFmpeg...
choco install python ffmpeg -y --no-progress
if %errorlevel% neq 0 (
    echo ERROR: Failed to install Python or FFmpeg.
    pause
    exit /b
)
echo Python and FFmpeg installed successfully.

:: Add Python scripts directory to PATH for this session
for /f "tokens=*" %%i in ('python -c "import sys, os; print(os.path.join(os.path.dirname(sys.executable), 'Scripts'))"') do (
    set "PYTHON_SCRIPTS_PATH=%%i"
)
set "PATH=%PATH%;%PYTHON_SCRIPTS_PATH%"


:: ---------------------------------------------------------------------------------
:: 4. INSTALL PYTORCH (CPU Version)
:: ---------------------------------------------------------------------------------
echo.
echo [STEP 3/5] Installing PyTorch (CPU version)...
echo This is a large download and may take a while.
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
if %errorlevel% neq 0 (
    echo ERROR: Failed to install PyTorch.
    pause
    exit /b
)
echo PyTorch installed successfully.


:: ---------------------------------------------------------------------------------
:: 5. INSTALL WHISPER
:: ---------------------------------------------------------------------------------
echo.
echo [STEP 4/5] Installing OpenAI Whisper...
pip install -U openai-whisper
if %errorlevel% neq 0 (
    echo ERROR: Failed to install Whisper.
    pause
    exit /b
)
echo Whisper installed successfully.


:: ---------------------------------------------------------------------------------
:: 6. FINAL VERIFICATION
:: ---------------------------------------------------------------------------------
echo.
echo [STEP 5/5] Verifying installation...
where whisper >nul 2>nul
if %errorlevel% equ 0 (
    echo.
    echo ===================================================
    echo  SUCCESS! Whisper and all dependencies are installed.
    echo ===================================================
    echo.
    echo You can now use the 'whisper' command in a new
    echo Command Prompt or PowerShell window.
    echo.
    echo You can also use the 'launch_whisper_ui.bat'
    echo to start the web interface.
    echo.
) else (
    echo.
    echo ===================================================
    echo  ERROR: Whisper installation could not be verified.
    echo ===================================================
    echo.
    echo The script finished, but the 'whisper' command
    echo is not available in the PATH.
    echo Please try opening a NEW Command Prompt and type:
    echo   whisper --help
    echo.
    echo If that doesn't work, a system restart may be required.
    echo.
)
pause
