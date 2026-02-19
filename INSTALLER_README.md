# LED Badge Programmer - Installer Guide

Complete installers for macOS, Linux, and Windows that create isolated Python environments.

## For Less Digitally Literate Users

These installers are designed for conference participants who may not be comfortable with:
- Command-line interfaces
- Installing Python manually
- Managing dependencies
- Configuring USB permissions

**The installers handle everything automatically and create isolated environments that won't interfere with existing Python installations.**

---

## macOS Installer (Intel & Apple Silicon)

### What It Does
- ✅ Installs Homebrew (if not present)
- ✅ Installs Python 3.11 and hidapi
- ✅ Creates isolated virtual environment in `~/Applications/LEDBadgeProgrammer`
- ✅ Downloads and installs all application files
- ✅ Creates a launcher app in Applications folder
- ✅ Does NOT touch your existing Python installations

### How to Run

**Method 1: Terminal**
```bash
chmod +x macos_installer.sh
./macos_installer.sh
```

**Method 2: Double-click**
1. Right-click `macos_installer.sh`
2. Select "Open With" → "Terminal"

### After Installation
- Find "LED Badge Programmer" in your Applications folder
- Double-click to launch
- On first run, macOS may ask for permission to access USB devices

---

## Linux Installer (Debian/Ubuntu)

### What It Does
- ✅ Installs Python 3.11 and system dependencies via apt
- ✅ Creates isolated virtual environment in `~/.local/share/ledbadge`
- ✅ Downloads and installs all application files
- ✅ Sets up USB permissions (udev rules)
- ✅ Creates desktop launcher entry
- ✅ Does NOT touch your existing Python installations

### How to Run

**Method 1: Terminal**
```bash
chmod +x linux_installer.sh
./linux_installer.sh
```

**Method 2: File Manager**
1. Right-click `linux_installer.sh`
2. Select "Properties"
3. Check "Allow executing file as program"
4. Double-click to run

### After Installation
- Find "LED Badge Programmer" in your application menu
- Or run from terminal: `~/.local/share/ledbadge/launch.sh`
- The installer sets up USB permissions, but you may need to unplug and replug the badge

### Tested On
- Ubuntu 20.04, 22.04, 24.04
- Debian 11, 12
- Linux Mint 21, 22
- Pop!_OS 22.04

---

## Windows Installer

### What It Does
- ✅ Downloads and installs Python 3.11 (if needed)
- ✅ Guides you through USB driver installation
- ✅ Creates isolated virtual environment in `%LOCALAPPDATA%\LEDBadgeProgrammer`
- ✅ Downloads and installs all application files
- ✅ Creates Start Menu shortcut
- ✅ Does NOT touch your existing Python installations

### How to Run

**IMPORTANT: Must run as Administrator**

**Method 1: Right-click and "Run as Administrator"**
1. Right-click `windows_installer.ps1`
2. Select "Run with PowerShell"
3. If you see a security warning, click "More info" → "Run anyway"

**Method 2: From PowerShell (as Administrator)**
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
.\windows_installer.ps1
```

### USB Driver Installation
The installer will guide you through installing the libusb-win32 driver:
1. Download libusb-win32 from SourceForge (link opens automatically)
2. Extract the zip file
3. Run `inf-wizard.exe` as Administrator
4. Select the LED badge device (Vendor ID: 0416, Product ID: 5020)
5. Complete the wizard

### After Installation
- Find "LED Badge Programmer" in your Start Menu
- Or run: `%LOCALAPPDATA%\LEDBadgeProgrammer\launch.bat`

---

## Verification After Installation

To verify the installation worked:

1. **Connect your LED badge via USB**
2. **Launch the application**
3. **Type a test message**: "Hello World"
4. **Click "Program Badge"**
5. **Check your badge**: It should display the message!

---

## Troubleshooting

### macOS

**Problem: "Cannot be opened because it is from an unidentified developer"**
- Solution: Right-click the installer → "Open" → "Open" again

**Problem: Homebrew installation fails**
- Solution: Install Homebrew manually first: https://brew.sh

**Problem: "Permission denied" when accessing badge**
- Solution: The badge should work without sudo on macOS. Try unplugging and replugging.

### Linux

**Problem: apt-get commands fail**
- Solution: Run `sudo apt-get update` first

**Problem: "Permission denied" when programming badge**
- Solution: 
  1. Unplug and replug the badge (to apply udev rules)
  2. Log out and log back in
  3. If still fails, check: `ls -l /dev/hidraw*` and `groups $USER`

**Problem: Desktop launcher doesn't appear**
- Solution: Log out and log back in, or run: `update-desktop-database ~/.local/share/applications`

### Windows

**Problem: PowerShell script won't run**
- Solution: Run PowerShell as Administrator and execute:
  ```powershell
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
  ```

**Problem: Python installation hangs**
- Solution: Download Python manually from python.org and install with "Add to PATH" checked

**Problem: Badge not detected**
- Solution: 
  1. Make sure you installed the libusb-win32 driver
  2. Check Device Manager for the badge (should show under "libusb-win32 devices")
  3. Try a different USB port

**Problem: "vcruntime140.dll missing"**
- Solution: Install Visual C++ Redistributable from Microsoft

---

## Isolated Environment Details

Each installer creates a **completely isolated** Python environment:

### macOS
- Location: `~/Applications/LEDBadgeProgrammer/`
- Virtual environment: `~/Applications/LEDBadgeProgrammer/venv/`
- Python version: 3.11
- Packages: pyusb, hidapi, pillow (isolated in venv)

### Linux
- Location: `~/.local/share/ledbadge/`
- Virtual environment: `~/.local/share/ledbadge/venv/`
- Python version: 3.11
- Packages: pyusb, hidapi, pillow (isolated in venv)

### Windows
- Location: `%LOCALAPPDATA%\LEDBadgeProgrammer\`
- Virtual environment: `%LOCALAPPDATA%\LEDBadgeProgrammer\venv\`
- Python version: 3.11
- Packages: pyusb, hidapi, pillow (isolated in venv)

**These environments will NOT interfere with:**
- System Python installations
- Other Python projects
- pip packages installed globally
- Virtual environments in other projects

---

## Uninstallation

If you need to remove the application:

### macOS
```bash
rm -rf ~/Applications/LEDBadgeProgrammer
rm -rf ~/Applications/"LED Badge Programmer.app"
```

### Linux
```bash
rm -rf ~/.local/share/ledbadge
rm ~/.local/share/applications/led-badge-programmer.desktop
```

### Windows
1. Delete folder: `%LOCALAPPDATA%\LEDBadgeProgrammer`
2. Delete Start Menu shortcut: `%APPDATA%\Microsoft\Windows\Start Menu\Programs\LED Badge Programmer.lnk`

---

## For Conference Organizers

### Distribution Package

Create a distribution package with:

```
LED_Badge_Installer/
├── macos_installer.sh           (macOS installer)
├── linux_installer.sh           (Linux installer)
├── windows_installer.ps1        (Windows installer)
├── INSTALLER_README.md          (This file)
└── USB_DRIVER_GUIDE.pdf         (Optional: Visual guide for Windows USB driver)
```

### Recommended Distribution Methods

1. **USB Drives**: Copy the entire folder to USB drives for on-site distribution
2. **Download Link**: Host on a simple webpage or file sharing service
3. **QR Code**: Create a QR code linking to the download
4. **Email**: Send as attachment or download link

### Support Checklist

Print this checklist for conference help desk:

- ☐ Badge connected via USB?
- ☐ Correct installer for their OS?
- ☐ Ran installer as Administrator (Windows) or with proper permissions?
- ☐ USB driver installed (Windows only)?
- ☐ Badge unplugged and replugged after installation?
- ☐ Tried simple message like "Hello World" first?

---

## For Digitally Literate Users

If users already have Python and are comfortable with the command line, they can skip the installers and use the manual installation method:

**macOS:**
```bash
brew install python hidapi
pip3 install pyusb hidapi pillow
# Then just run: python3 led_badge_gui.py
```

**Linux:**
```bash
sudo apt-get install python3 python3-pip libhidapi-hidraw0
pip3 install pyusb hidapi pillow
# Then just run: python3 led_badge_gui.py
```

**Windows:**
```bash
pip install pyusb hidapi pillow
# Install USB driver, then run: python led_badge_gui.py
```

---

## Technical Notes

### Why Isolated Environments?

The installers use Python virtual environments (venv) to:
1. Avoid conflicts with existing Python installations
2. Prevent "works on my machine" issues
3. Make it easy to distribute and uninstall
4. Ensure consistent behavior across all users

### Security Considerations

The installers:
- Download Python from python.org (official source)
- Download lednamebadge.py from the official GitHub repository
- Do not execute arbitrary remote code
- Only install well-known, vetted packages (pyusb, hidapi, pillow)
- Request admin/sudo only when necessary (system packages, USB permissions)

### System Requirements

**macOS:**
- macOS 10.13 (High Sierra) or later
- Intel or Apple Silicon processor
- 200 MB free disk space

**Linux:**
- Debian-based distribution (Ubuntu, Debian, Mint, Pop!_OS, etc.)
- systemd-based system (for udev rules)
- 200 MB free disk space

**Windows:**
- Windows 10 or later (Windows 11 supported)
- 64-bit system
- 300 MB free disk space
- Administrator access

---

## Questions or Issues?

For conference-specific questions, contact your conference organizers.

For technical issues with the LED badge library, see:
https://github.com/fossasia/led-name-badge-ls32

For installer issues, check the Troubleshooting section above.

---

**Enjoy your LED badges! 🎉**
