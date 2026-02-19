#!/bin/bash
# LED Badge Programmer Launcher for macOS/Linux

echo "======================================"
echo "  LED Badge Programmer"
echo "======================================"
echo ""

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is not installed!"
    echo "Please install Python 3 from python.org"
    exit 1
fi

# Check if lednamebadge.py exists
if [ ! -f "lednamebadge.py" ]; then
    echo "Error: lednamebadge.py not found!"
    echo "Please make sure lednamebadge.py is in the same directory."
    exit 1
fi

# Launch the GUI
echo "Starting LED Badge GUI..."
echo ""

python3 led_badge_gui.py

# Keep terminal open on error
if [ $? -ne 0 ]; then
    echo ""
    echo "Press Enter to close..."
    read
fi
