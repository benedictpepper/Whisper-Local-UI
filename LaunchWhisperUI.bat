@echo off
REM =================================================================
REM Whisper UI Auto-Launcher
REM =================================================================
REM This script starts the Python server and automatically opens
REM the user interface in your default web browser.
REM =================================================================

REM This command changes the directory to the one where this script is located.
cd /d "%~dp0"

echo ===================================================
echo  Starting Whisper UI Server...
echo ===================================================
echo.
echo This window must remain open to use the app.
echo Close this window to shut down the server.
echo.
echo ===================================================
echo.

REM --- Automatically launch the browser ---
echo Waiting for the server to start...
REM Wait for 3 seconds to give the server time to initialize.
timeout /t 3 /nobreak > nul

echo Launching the UI in your default browser...
start http://127.0.0.1:5000

REM --- Run the Python server ---
REM The script will stay on this line until you close the window.
python server.py

echo.
echo Server has been shut down.
pause
