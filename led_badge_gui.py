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
