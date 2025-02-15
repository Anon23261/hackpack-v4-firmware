#!/usr/bin/env python3
import subprocess
import os
import signal
import sys
import threading
from pathlib import Path
import RPi.GPIO as GPIO
from time import sleep

class ToolsHandler:
    def __init__(self):
        self.home = str(Path.home())
        self.current_process = None
        self.stop_requested = False
        
        # RGB LED pins
        self.rgb_pins = {
            'r': 16,  # Red channel
            'g': 20,  # Green channel
            'b': 21   # Blue channel
        }
        self.blink_thread = None
        self.should_blink = False
        
        # Color combinations for states
        self.colors = {
            'red': {'r': 1, 'g': 0, 'b': 0},      # Error/Stop
            'green': {'r': 0, 'g': 1, 'b': 0},    # Success
            'blue': {'r': 0, 'g': 0, 'b': 1},     # Processing
            'purple': {'r': 1, 'g': 0, 'b': 1},   # Stalled
            'cyan': {'r': 0, 'g': 1, 'b': 1},     # In-process
            'white': {'r': 1, 'g': 1, 'b': 1}     # All on
        }
        self.setup_leds()

    def setup_leds(self):
        GPIO.setmode(GPIO.BCM)
        for pin in self.rgb_pins.values():
            GPIO.setup(pin, GPIO.OUT)
            GPIO.output(pin, GPIO.LOW)
            
    def set_color(self, color_name):
        color = self.colors.get(color_name, {'r': 0, 'g': 0, 'b': 0})
        for channel, value in color.items():
            GPIO.output(self.rgb_pins[channel], value)

    def led_feedback(self, color, duration=0.5, blink=False):
        if blink:
            self.start_blinking(color)
        else:
            self.stop_blinking()
            self.set_color(color)
            sleep(duration)
            self.set_color('off')

    def start_blinking(self, color):
        self.stop_blinking()
        self.should_blink = True
        self.blink_thread = threading.Thread(target=self._blink_led, args=(color,))
        self.blink_thread.daemon = True
        self.blink_thread.start()

    def stop_blinking(self):
        self.should_blink = False
        if self.blink_thread:
            self.blink_thread.join(timeout=1)
            self.blink_thread = None
        self.set_color('off')

    def _blink_led(self, color):
        while self.should_blink:
            self.set_color(color)
            sleep(0.5)
            self.set_color('off')
            sleep(0.5)

    def run_command(self, cmd, cwd=None):
        if self.current_process:
            self.stop_current_process()
        
        if cwd is None:
            cwd = self.home
        
        try:
            # Start cyan blinking for in-process
            self.led_feedback('cyan', blink=True)
            
            self.current_process = subprocess.Popen(
                cmd,
                shell=True,
                cwd=cwd,
                preexec_fn=os.setsid
            )
            
            # Monitor process state in a separate thread
            threading.Thread(target=self._monitor_process, daemon=True).start()
            
        except Exception as e:
            self.stop_blinking()
            self.led_feedback('red', 1.0)
            print(f"Error running command: {e}")

    def _monitor_process(self):
        if not self.current_process:
            return

        last_cpu_time = 0
        stall_count = 0

        while self.current_process:
            try:
                # Check if process is still running
                if self.current_process.poll() is not None:
                    self.stop_blinking()
                    self.led_feedback('green', 1.0)
                    break

                # Get process CPU time
                with open(f"/proc/{self.current_process.pid}/stat") as f:
                    cpu_time = sum(map(int, f.read().split()[13:15]))

                # If CPU time hasn't changed, might be stalled
                if cpu_time == last_cpu_time:
                    stall_count += 1
                else:
                    stall_count = 0
                    last_cpu_time = cpu_time

                # If stalled for 5 checks (5 seconds), show solid purple
                if stall_count >= 5:
                    self.stop_blinking()
                    self.set_color('purple')

                sleep(1)

            except (ProcessLookupError, FileNotFoundError):
                break

    def stop_current_process(self):
        if self.current_process:
            try:
                self.stop_blinking()
                self.set_color('off')
                os.killpg(os.getpgid(self.current_process.pid), signal.SIGTERM)
                self.led_feedback('red', 0.5)
            except:
                pass
            self.current_process = None

    # Button A: IPython Shell
    def button_a_action(self):
        cmd = "ipython3"
        self.run_command(cmd)

    # Button B: Run Current Python File
    def button_b_action(self):
        current_dir = os.getcwd()
        python_files = [f for f in os.listdir(current_dir) if f.endswith('.py')]
        if python_files:
            cmd = f"python3 {python_files[0]}"
            self.run_command(cmd, current_dir)
        else:
            self.led_feedback('red')
            print("No Python files found in current directory")

    # Button X: Code Quality & Tests
    def button_x_action(self):
        current_dir = os.getcwd()
        cmd = "black . && pylint *.py && pytest"
        self.run_command(cmd, current_dir)

    # Button Y: USB Payload Generator
    def button_y_action(self):
        payload_dir = f"{self.home}/projects/payloads"
        if not os.path.exists(payload_dir):
            os.makedirs(payload_dir)
        cmd = f"cd {payload_dir} && python3 generate_payload.py"
        self.run_command(cmd)

    # Start: Jupyter Notebook
    def button_start_action(self):
        cmd = "jupyter notebook --ip=0.0.0.0 --no-browser"
        self.run_command(cmd)

    # Select: Stop Current Process
    def button_select_action(self):
        self.stop_current_process()

tools_handler = ToolsHandler()
