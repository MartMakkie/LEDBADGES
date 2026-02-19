#!/bin/bash
# LED Badge Programmer - Linux (Debian/Ubuntu) Installer
# Creates an isolated Python environment and installs the application

set -e  # Exit on error

VERSION="1.0.0"
APP_NAME="LED Badge Programmer"
INSTALL_DIR="$HOME/.local/share/ledbadge"
DESKTOP_FILE="$HOME/.local/share/applications/led-badge-programmer.desktop"
PYTHON_VERSION="3.11"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  ${APP_NAME} - Installer"
echo "  Version ${VERSION}"
echo "════════════════════════════════════════════════════════════"
echo ""

# Function to print colored messages
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    print_error "Please do not run this installer as root or with sudo."
    print_info "The installer will ask for your password when needed."
    exit 1
fi

echo ""
print_info "This installer will:"
echo "  • Install system dependencies (requires sudo)"
echo "  • Create an isolated Python environment in: $INSTALL_DIR"
echo "  • Install all required dependencies"
echo "  • Create a desktop launcher"
echo "  • Set up USB permissions (udev rules)"
echo "  • NOT interfere with your existing Python installations"
echo ""

read -p "Continue with installation? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_warning "Installation cancelled."
    exit 0
fi

echo ""
print_info "Starting installation..."
echo ""

# Step 1: Update package list and install system dependencies
print_info "[1/7] Installing system dependencies (requires sudo)..."
echo ""

sudo apt-get update
sudo apt-get install -y \
    python3.11 \
    python3.11-venv \
    python3-pip \
    libhidapi-hidraw0 \
    libhidapi-libusb0

print_success "System dependencies installed"

# Step 2: Create installation directory
print_info "[2/7] Creating installation directory..."
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"
print_success "Installation directory created"

# Step 3: Create virtual environment
print_info "[3/7] Creating isolated Python environment..."
python3.11 -m venv venv
source venv/bin/activate
print_success "Virtual environment created"

# Step 4: Install Python packages
print_info "[4/7] Installing Python packages..."
pip install --upgrade pip > /dev/null 2>&1
pip install pyusb hidapi pillow > /dev/null 2>&1
print_success "Python packages installed"

# Step 5: Copy application files
print_info "[5/7] Installing application files..."

# Write the GUI application
cat > "$INSTALL_DIR/led_badge_gui.py" << 'PYTHON_GUI_EOF'
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
PYTHON_GUI_EOF

print_info "Downloading lednamebadge.py from repository..."
curl -sL https://raw.githubusercontent.com/fossasia/led-name-badge-ls32/master/lednamebadge.py -o "$INSTALL_DIR/lednamebadge.py"

chmod +x "$INSTALL_DIR/led_badge_gui.py"
print_success "Application files installed"

# Step 6: Set up USB permissions (udev rules)
print_info "[6/7] Setting up USB permissions (requires sudo)..."
echo ""

sudo tee /etc/udev/rules.d/99-led-badge.rules > /dev/null << UDEV_EOF
# LED Name Badge USB permissions
SUBSYSTEM=="usb", ATTR{idVendor}=="0416", ATTR{idProduct}=="5020", MODE="0666"
SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0416", ATTRS{idProduct}=="5020", MODE="0666"
UDEV_EOF

sudo udevadm control --reload-rules
sudo udevadm trigger

print_success "USB permissions configured"
print_info "Note: You may need to unplug and replug your badge"

# Step 7: Create launcher script and desktop entry
print_info "[7/7] Creating launcher..."

cat > "$INSTALL_DIR/launch.sh" << 'LAUNCHER_EOF'
#!/bin/bash
# LED Badge Programmer Launcher

# Get the directory where this script is located
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Activate virtual environment
source "$DIR/venv/bin/activate"

# Launch the GUI
cd "$DIR"
python led_badge_gui.py

# Deactivate when done
deactivate
LAUNCHER_EOF

chmod +x "$INSTALL_DIR/launch.sh"

# Create desktop entry
mkdir -p "$(dirname "$DESKTOP_FILE")"

cat > "$DESKTOP_FILE" << DESKTOP_EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=LED Badge Programmer
Comment=Program LED name badges
Exec=$INSTALL_DIR/launch.sh
Icon=preferences-desktop-display
Terminal=false
Categories=Utility;
Keywords=LED;Badge;USB;
DESKTOP_EOF

chmod +x "$DESKTOP_FILE"

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
fi

print_success "Launcher created"

echo ""
echo "════════════════════════════════════════════════════════════"
print_success "Installation completed successfully!"
echo "════════════════════════════════════════════════════════════"
echo ""
print_info "The application has been installed to:"
echo "  $INSTALL_DIR"
echo ""
print_info "You can launch it from:"
echo "  • Application menu: 'LED Badge Programmer'"
echo "  • Or run: $INSTALL_DIR/launch.sh"
echo ""
print_info "This installation is completely isolated and will not"
print_info "interfere with any other Python installations on your system."
echo ""
print_warning "IMPORTANT: Unplug and replug your LED badge to apply USB permissions."
echo ""
read -p "Press Enter to exit..."
