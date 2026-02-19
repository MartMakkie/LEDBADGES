# LED Badge Programmer - Windows Installer
# Creates an isolated Python environment and installs the application

$ErrorActionPreference = "Stop"

$VERSION = "1.0.0"
$APP_NAME = "LED Badge Programmer"
$INSTALL_DIR = "$env:LOCALAPPDATA\LEDBadgeProgrammer"
$PYTHON_VERSION = "3.11.7"
$PYTHON_URL = "https://www.python.org/ftp/python/3.11.7/python-3.11.7-amd64.exe"

# Function to print colored messages
function Print-Success {
    param($message)
    Write-Host "✓ $message" -ForegroundColor Green
}

function Print-Info {
    param($message)
    Write-Host "ℹ $message" -ForegroundColor Cyan
}

function Print-Warning {
    param($message)
    Write-Host "⚠ $message" -ForegroundColor Yellow
}

function Print-Error {
    param($message)
    Write-Host "✗ $message" -ForegroundColor Red
}

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

Clear-Host
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════=" -ForegroundColor White
Write-Host "  $APP_NAME - Installer" -ForegroundColor White
Write-Host "  Version $VERSION" -ForegroundColor White
Write-Host "═══════════════════════════════════════════════════════════=" -ForegroundColor White
Write-Host ""

if (-not $isAdmin) {
    Print-Warning "This installer requires administrator privileges for USB driver installation."
    Print-Info "Please right-click this script and select 'Run as Administrator'"
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Print-Info "This installer will:"
Write-Host "  • Download and install Python $PYTHON_VERSION (if needed)"
Write-Host "  • Install USB drivers for the LED badge"
Write-Host "  • Create an isolated Python environment in: $INSTALL_DIR"
Write-Host "  • Install all required dependencies"
Write-Host "  • Create a Start Menu shortcut"
Write-Host "  • NOT interfere with your existing Python installations"
Write-Host ""

$response = Read-Host "Continue with installation? (Y/N)"
if ($response -notmatch "^[Yy]$") {
    Print-Warning "Installation cancelled."
    exit 0
}

Write-Host ""
Print-Info "Starting installation..."
Write-Host ""

# Step 1: Check for Python
Print-Info "[1/8] Checking for Python..."

$pythonInstalled = $false
$pythonPath = $null

# Check for Python in PATH
try {
    $pythonVersion = & python --version 2>&1
    if ($pythonVersion -match "Python 3\.(1[01]|[89])\.") {
        $pythonPath = "python"
        $pythonInstalled = $true
        Print-Success "Python found in PATH: $pythonVersion"
    }
} catch {}

if (-not $pythonInstalled) {
    Print-Info "Python not found. Downloading Python $PYTHON_VERSION..."
    
    $pythonInstaller = "$env:TEMP\python-installer.exe"
    
    try {
        Invoke-WebRequest -Uri $PYTHON_URL -OutFile $pythonInstaller
        Print-Success "Python installer downloaded"
        
        Print-Info "Installing Python (this may take a few minutes)..."
        Start-Process -FilePath $pythonInstaller -ArgumentList "/quiet", "InstallAllUsers=0", "PrependPath=1", "Include_pip=1" -Wait
        
        # Refresh environment variables
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","User") + ";" + [System.Environment]::GetEnvironmentVariable("Path","Machine")
        
        Remove-Item $pythonInstaller -Force
        Print-Success "Python installed successfully"
        
        $pythonPath = "python"
    } catch {
        Print-Error "Failed to install Python: $_"
        Read-Host "Press Enter to exit"
        exit 1
    }
} else {
    Print-Success "Python already installed"
}

# Step 2: Install USB drivers
Print-Info "[2/8] Installing USB drivers..."
Print-Warning "You will need to manually install the libusb-win32 driver."
Print-Info "Opening instructions in browser..."

Start-Process "https://github.com/fossasia/led-name-badge-ls32#windows-install"

Write-Host ""
Print-Info "Please follow these steps:"
Write-Host "  1. Download libusb-win32 from the link that just opened"
Write-Host "  2. Extract the zip file"
Write-Host "  3. Run inf-wizard.exe as Administrator"
Write-Host "  4. Follow the wizard to install the driver for your LED badge"
Write-Host ""
$driverReady = Read-Host "Have you installed the USB driver? (Y/N)"

if ($driverReady -notmatch "^[Yy]$") {
    Print-Warning "Installation cancelled. Please install the USB driver first."
    Read-Host "Press Enter to exit"
    exit 0
}

Print-Success "USB driver confirmed"

# Step 3: Create installation directory
Print-Info "[3/8] Creating installation directory..."
New-Item -ItemType Directory -Path $INSTALL_DIR -Force | Out-Null
Set-Location $INSTALL_DIR
Print-Success "Installation directory created"

# Step 4: Create virtual environment
Print-Info "[4/8] Creating isolated Python environment..."
& $pythonPath -m venv venv
Print-Success "Virtual environment created"

# Step 5: Activate virtual environment and install packages
Print-Info "[5/8] Installing Python packages (this may take a minute)..."

$venvPython = Join-Path $INSTALL_DIR "venv\Scripts\python.exe"
$venvPip = Join-Path $INSTALL_DIR "venv\Scripts\pip.exe"

& $venvPip install --upgrade pip | Out-Null
& $venvPip install pyusb hidapi pillow | Out-Null

Print-Success "Python packages installed"

# Step 6: Download application files
Print-Info "[6/8] Installing application files..."

# Download lednamebadge.py
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/fossasia/led-name-badge-ls32/master/lednamebadge.py" -OutFile "$INSTALL_DIR\lednamebadge.py"

# Create GUI application
$guiContent = @'
#!/usr/bin/env python3
# -*- encoding: utf-8 -*-
"""
LED Name Badge GUI
A cross-platform graphical interface for programming LED name badges
"""

import tkinter as tk
from tkinter import ttk, scrolledtext, messagebox
import sys
from array import array

# Import the LED badge library
try:
    from lednamebadge import LedNameBadge, SimpleTextAndIcons
except ImportError:
    print("Error: lednamebadge.py not found!")
    print("Please make sure lednamebadge.py is in the same directory as this script.")
    sys.exit(1)


class LEDBadgeGUI:
    def __init__(self, root):
        self.root = root
        self.root.title("LED Badge Programmer")
        self.root.geometry("900x700")
        
        # Configure style
        style = ttk.Style()
        style.theme_use('clam')
        
        # Effect mapping (mode parameter)
        self.effects = {
            "Left": 0,
            "Right": 1,
            "Up": 2,
            "Down": 3,
            "Fixed": 4,
            "Animation": 5,
            "Drop Down": 6,
            "Curtain": 7,
            "Laser": 8
        }
        
        # Initialize message data (8 messages)
        self.messages = []
        for i in range(8):
            self.messages.append({
                'text': tk.StringVar(value=""),
                'speed': tk.IntVar(value=4),
                'effect': tk.StringVar(value="Left"),
                'flash': tk.BooleanVar(value=False),
                'border': tk.BooleanVar(value=False)
            })
        
        self.create_widgets()
    
    def create_widgets(self):
        # Main container with padding
        main_frame = ttk.Frame(self.root, padding="10")
        main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # Configure grid weights for resizing
        self.root.columnconfigure(0, weight=1)
        self.root.rowconfigure(0, weight=1)
        main_frame.columnconfigure(0, weight=1)
        main_frame.rowconfigure(1, weight=1)
        
        # Title
        title_label = ttk.Label(main_frame, text="LED Name Badge Programmer", 
                               font=('Helvetica', 16, 'bold'))
        title_label.grid(row=0, column=0, pady=(0, 10))
        
        # Create notebook (tabs) for messages
        self.notebook = ttk.Notebook(main_frame)
        self.notebook.grid(row=1, column=0, sticky=(tk.W, tk.E, tk.N, tk.S), pady=(0, 10))
        
        # Create a tab for each message slot
        for i in range(8):
            frame = self.create_message_frame(i)
            self.notebook.add(frame, text=f"Message {i+1}")
        
        # Bottom frame for global controls
        bottom_frame = ttk.Frame(main_frame)
        bottom_frame.grid(row=2, column=0, sticky=(tk.W, tk.E), pady=(10, 0))
        bottom_frame.columnconfigure(0, weight=1)
        
        # Brightness control
        brightness_frame = ttk.Frame(bottom_frame)
        brightness_frame.grid(row=0, column=0, sticky=(tk.W, tk.E), pady=(0, 10))
        
        ttk.Label(brightness_frame, text="Brightness:").pack(side=tk.LEFT, padx=(0, 10))
        self.brightness = tk.IntVar(value=100)
        brightness_scale = ttk.Scale(brightness_frame, from_=25, to=100, 
                                    variable=self.brightness, orient=tk.HORIZONTAL,
                                    length=200)
        brightness_scale.pack(side=tk.LEFT, padx=(0, 10))
        
        brightness_label = ttk.Label(brightness_frame, textvariable=self.brightness)
        brightness_label.pack(side=tk.LEFT)
        ttk.Label(brightness_frame, text="%").pack(side=tk.LEFT)
        
        # Program button
        self.program_btn = ttk.Button(bottom_frame, text="Program Badge", 
                                      command=self.program_badge,
                                      style='Accent.TButton')
        self.program_btn.grid(row=1, column=0, pady=(5, 0))
        
        # Style for the program button
        style = ttk.Style()
        style.configure('Accent.TButton', font=('Helvetica', 12, 'bold'))
        
        # Status bar
        self.status_var = tk.StringVar(value="Ready")
        status_bar = ttk.Label(main_frame, textvariable=self.status_var, 
                              relief=tk.SUNKEN, anchor=tk.W)
        status_bar.grid(row=3, column=0, sticky=(tk.W, tk.E), pady=(10, 0))
    
    def create_message_frame(self, index):
        """Create a frame for one message slot"""
        frame = ttk.Frame(self.notebook, padding="20")
        frame.columnconfigure(1, weight=1)
        
        msg = self.messages[index]
        
        # Message text
        row = 0
        ttk.Label(frame, text="Message Text:", font=('Helvetica', 10, 'bold')).grid(
            row=row, column=0, columnspan=2, sticky=tk.W, pady=(0, 5))
        
        row += 1
        text_entry = ttk.Entry(frame, textvariable=msg['text'], font=('Helvetica', 11))
        text_entry.grid(row=row, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=(0, 15))
        
        # Speed control
        row += 1
        ttk.Label(frame, text="Speed:", font=('Helvetica', 10)).grid(
            row=row, column=0, sticky=tk.W, pady=(5, 5))
        
        speed_frame = ttk.Frame(frame)
        speed_frame.grid(row=row, column=1, sticky=(tk.W, tk.E), pady=(5, 5))
        
        speed_scale = ttk.Scale(speed_frame, from_=1, to=8, 
                               variable=msg['speed'], orient=tk.HORIZONTAL)
        speed_scale.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(0, 10))
        
        speed_label = ttk.Label(speed_frame, textvariable=msg['speed'], width=2)
        speed_label.pack(side=tk.LEFT)
        
        # Effect (mode)
        row += 1
        ttk.Label(frame, text="Effect:", font=('Helvetica', 10)).grid(
            row=row, column=0, sticky=tk.W, pady=(5, 5))
        
        effect_combo = ttk.Combobox(frame, textvariable=msg['effect'], 
                                   values=list(self.effects.keys()),
                                   state='readonly', width=15)
        effect_combo.grid(row=row, column=1, sticky=tk.W, pady=(5, 5))
        
        # Flash (blink)
        row += 1
        flash_check = ttk.Checkbutton(frame, text="Flash/Blink", 
                                     variable=msg['flash'])
        flash_check.grid(row=row, column=0, columnspan=2, sticky=tk.W, pady=(5, 5))
        
        # Border (ants)
        row += 1
        border_check = ttk.Checkbutton(frame, text="Animated Border", 
                                      variable=msg['border'])
        border_check.grid(row=row, column=0, columnspan=2, sticky=tk.W, pady=(5, 5))
        
        # Help text
        row += 1
        help_frame = ttk.LabelFrame(frame, text="Tips", padding="10")
        help_frame.grid(row=row, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=(20, 0))
        
        help_text = (
            "• You can use built-in icons in your text using colons, e.g., :heart: or :HEART2:\n"
            "• Speed: 1 = slowest, 8 = fastest\n"
            "• Flash makes the message blink on/off\n"
            "• Animated Border adds a moving border effect\n"
            "• Leave message empty if you don't want to use all 8 slots"
        )
        
        help_label = ttk.Label(help_frame, text=help_text, justify=tk.LEFT, 
                              foreground='#555')
        help_label.pack()
        
        return frame
    
    def program_badge(self):
        """Program the badge with current settings"""
        try:
            self.status_var.set("Programming badge...")
            self.program_btn.config(state='disabled')
            self.root.update()
            
            # Create bitmap creator
            creator = SimpleTextAndIcons()
            
            # Collect all non-empty messages
            msg_bitmaps = []
            speeds = []
            modes = []
            blinks = []
            ants = []
            
            for msg_data in self.messages:
                text = msg_data['text'].get().strip()
                if text:  # Only include non-empty messages
                    msg_bitmaps.append(creator.bitmap(text))
                    speeds.append(msg_data['speed'].get())
                    modes.append(self.effects[msg_data['effect'].get()])
                    blinks.append(1 if msg_data['flash'].get() else 0)
                    ants.append(1 if msg_data['border'].get() else 0)
            
            if not msg_bitmaps:
                messagebox.showwarning("No Messages", 
                                      "Please enter at least one message!")
                self.status_var.set("Ready")
                self.program_btn.config(state='normal')
                return
            
            # Get message lengths
            lengths = [b[1] for b in msg_bitmaps]
            
            # Get brightness
            brightness = self.brightness.get()
            
            # Build the data buffer
            buf = array('B')
            buf.extend(LedNameBadge.header(lengths, speeds, modes, blinks, ants, brightness))
            
            for msg_bitmap in msg_bitmaps:
                buf.extend(msg_bitmap[0])
            
            # Write to badge
            LedNameBadge.write(buf, 'auto', 'auto')
            
            self.status_var.set("Badge programmed successfully!")
            messagebox.showinfo("Success", 
                               "Your LED badge has been programmed successfully!\n\n"
                               f"Messages programmed: {len(msg_bitmaps)}")
            
        except Exception as e:
            error_msg = str(e)
            self.status_var.set(f"Error: {error_msg}")
            messagebox.showerror("Programming Error", 
                               f"Failed to program badge:\n\n{error_msg}\n\n"
                               "Make sure:\n"
                               "• Your badge is connected via USB\n"
                               "• You have the necessary permissions\n"
                               "• The hidapi library is installed")
        finally:
            self.program_btn.config(state='normal')


def main():
    """Main entry point"""
    root = tk.Tk()
    app = LEDBadgeGUI(root)
    root.mainloop()


if __name__ == '__main__':
    main()
'@

Set-Content -Path "$INSTALL_DIR\led_badge_gui.py" -Value $guiContent

Print-Success "Application files installed"

# Step 7: Create launcher batch file
Print-Info "[7/8] Creating launcher..."

$launcherContent = @"
@echo off
REM LED Badge Programmer Launcher

REM Activate virtual environment
call "$INSTALL_DIR\venv\Scripts\activate.bat"

REM Launch the GUI
cd /d "$INSTALL_DIR"
python led_badge_gui.py

REM Deactivate when done
deactivate
"@

Set-Content -Path "$INSTALL_DIR\launch.bat" -Value $launcherContent

Print-Success "Launcher created"

# Step 8: Create Start Menu shortcut
Print-Info "[8/8] Creating Start Menu shortcut..."

$WshShell = New-Object -ComObject WScript.Shell
$StartMenuPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
$Shortcut = $WshShell.CreateShortcut("$StartMenuPath\LED Badge Programmer.lnk")
$Shortcut.TargetPath = "$INSTALL_DIR\launch.bat"
$Shortcut.WorkingDirectory = $INSTALL_DIR
$Shortcut.Description = "Program LED name badges"
$Shortcut.Save()

Print-Success "Start Menu shortcut created"

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════=" -ForegroundColor White
Print-Success "Installation completed successfully!"
Write-Host "═══════════════════════════════════════════════════════════=" -ForegroundColor White
Write-Host ""
Print-Info "The application has been installed to:"
Write-Host "  $INSTALL_DIR"
Write-Host ""
Print-Info "You can launch it from:"
Write-Host "  • Start Menu: 'LED Badge Programmer'"
Write-Host "  • Or run: $INSTALL_DIR\launch.bat"
Write-Host ""
Print-Info "This installation is completely isolated and will not"
Print-Info "interfere with any other Python installations on your system."
Write-Host ""
Read-Host "Press Enter to exit"
