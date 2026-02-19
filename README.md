# LED Badge GUI - User Guide

A simple, cross-platform graphical interface for programming LED name badges.

## Installation

### Prerequisites

1. **Python 3.6 or higher** - Download from [python.org](https://www.python.org/downloads/)

2. **hidapi library** - Required for USB communication

   **macOS:**
   ```bash
   brew install hidapi
   ```

   **Linux (Ubuntu/Debian):**
   ```bash
   sudo apt-get install libhidapi-hidraw0
   ```

   **Windows:**
   Follow the instructions in the lednamebadge.py comments for setting up libusb-win32

3. **Python packages:**
   ```bash
   pip install pyusb hidapi pillow
   ```
   
   (Note: On some systems you may need to use `pip3` instead of `pip`)

### Files Needed

Make sure you have both files in the same directory:
- `lednamebadge.py` (the original library from the GitHub repo)
- `led_badge_gui.py` (this GUI application)

## Running the GUI

### macOS/Linux:
```bash
python3 led_badge_gui.py
```

### Windows:
```bash
python led_badge_gui.py
```

**Note:** On Linux, you may need to run with sudo for USB permissions:
```bash
sudo python3 led_badge_gui.py
```

Or better yet, set up udev rules (see the main repo README for details).

## Using the GUI

### Main Features

The interface provides 8 message slots (tabs), each with the following controls:

1. **Message Text** - Enter your text here
   - You can use built-in icons like `:heart:`, `:HEART2:`, etc.
   - To see all available icons, run: `python lednamebadge.py -l`

2. **Speed** (1-8)
   - 1 = slowest scroll
   - 8 = fastest scroll

3. **Effect** - How the text appears:
   - **Left** - Scrolls from right to left (default)
   - **Right** - Scrolls from left to right
   - **Up** - Scrolls from bottom to top
   - **Down** - Scrolls from top to bottom
   - **Fixed** - Text stays centered (no scroll)
   - **Animation** - For animated frames
   - **Drop Down** - Text drops down
   - **Curtain** - Curtain effect
   - **Laser** - Laser effect

4. **Flash/Blink** - Makes the message blink on and off

5. **Animated Border** - Adds a moving border around the display

6. **Brightness** - Global brightness control (25%, 50%, 75%, or 100%)

### Step-by-Step Guide

1. **Connect your LED badge** via USB to your computer

2. **Launch the GUI** application

3. **Enter your messages**:
   - Click on "Message 1" tab
   - Type your text in the text box
   - Adjust speed, effect, and other settings as desired
   - Repeat for additional messages (you can use up to 8)

4. **Set brightness** using the slider at the bottom

5. **Click "Program Badge"** to upload your messages

6. **Wait for confirmation** - You'll see a success message when done!

### Tips & Tricks

- **You don't need to fill all 8 slots** - just leave unused ones empty
- **Test with simple text first** - Try "Hello World" to make sure everything works
- **Icon usage** - Use colons around icon names, e.g., `:heart:` or `:smiley:`
- **Mix icons and text** - You can write: "I :heart: Python"
- **Animation mode** requires special 48px-wide images
- **For best results** on conference badges, use messages 2-4 with clear, short text

### Common Issues

**"Could not find the hidapi shared library"**
- Make sure you installed hidapi system library (see Prerequisites above)

**"Permission denied" or USB access errors**
- On Linux: Run with `sudo` or set up udev rules
- On macOS: Generally works without sudo after installing hidapi
- On Windows: Make sure you installed libusb-win32 drivers

**Badge not detected**
- Check that the USB cable is properly connected
- Try a different USB port
- Make sure the badge is turned on

**GUI won't start**
- Check that Python 3 is installed: `python3 --version`
- Make sure tkinter is available (usually comes with Python)
- Verify both `lednamebadge.py` and `led_badge_gui.py` are in the same folder

## Advanced Usage

For command-line usage and more advanced features, refer to the original repository:
https://github.com/fossasia/led-name-badge-ls32

## Packaging for Conference

### For Conference Attendees

You can create a simple package with:

1. **Create a folder** named `LED_Badge_Programmer`

2. **Add these files**:
   - `led_badge_gui.py`
   - `lednamebadge.py`
   - `README.md` (this file)
   - `INSTALL.txt` (with platform-specific quick start)

3. **Create platform-specific launchers**:

   **macOS/Linux - `start.sh`:**
   ```bash
   #!/bin/bash
   python3 led_badge_gui.py
   ```
   Make executable: `chmod +x start.sh`

   **Windows - `start.bat`:**
   ```batch
   @echo off
   python led_badge_gui.py
   pause
   ```

4. **Zip it up** and distribute!

### Quick Install Instructions for Attendees

**macOS:**
```bash
# Install Homebrew if not installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
brew install python hidapi
pip3 install pyusb hidapi pillow

# Run the GUI
python3 led_badge_gui.py
```

**Linux:**
```bash
# Install dependencies
sudo apt-get update
sudo apt-get install python3 python3-pip libhidapi-hidraw0
pip3 install pyusb hidapi pillow

# Run the GUI (with sudo for USB access)
sudo python3 led_badge_gui.py
```

**Windows:**
1. Download and install Python from python.org
2. Open Command Prompt as Administrator
3. Run: `pip install pyusb hidapi pillow`
4. Set up libusb-win32 (see Windows section in lednamebadge.py)
5. Double-click `start.bat` or run `python led_badge_gui.py`

## License

This GUI is released under the same license as the original led-name-badge-ls32 project.
Original project: https://github.com/fossasia/led-name-badge-ls32

## Support

For issues with:
- **The GUI**: Open an issue describing the problem
- **The badge protocol/library**: Refer to the original repository
- **Conference-specific questions**: Contact your conference organizers

---

Enjoy your LED badges! 
