@echo off
REM LED Badge Programmer Launcher for Windows

echo ======================================
echo   LED Badge Programmer
echo ======================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Python is not installed or not in PATH!
    echo Please install Python from python.org
    echo.
    pause
    exit /b 1
)

REM Check if lednamebadge.py exists
if not exist "lednamebadge.py" (
    echo Error: lednamebadge.py not found!
    echo Please make sure lednamebadge.py is in the same directory.
    echo.
    pause
    exit /b 1
)

REM Launch the GUI
echo Starting LED Badge GUI...
echo.

python led_badge_gui.py

REM Keep window open on error
if %errorlevel% neq 0 (
    echo.
    echo An error occurred. Check the message above.
    pause
)
