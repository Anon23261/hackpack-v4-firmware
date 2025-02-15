#!/usr/bin/env python3
"""
Quick verification script for HackPack v4 core functionality.
Tests essential components without requiring full test suite.
"""

import sys
import os
import time
from pathlib import Path

def print_status(msg, success=None):
    """Print status message with color."""
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[93m'
    RESET = '\033[0m'
    
    if success is None:
        color = YELLOW
        prefix = "⚡"
    elif success:
        color = GREEN
        prefix = "✓"
    else:
        color = RED
        prefix = "✗"
    
    print(f"{color}{prefix} {msg}{RESET}")

def check_imports():
    """Verify all required packages are installed."""
    required_packages = [
        'RPi.GPIO',
        'spidev',
        'fastapi',
        'rich',
        'uvicorn'
    ]
    
    missing = []
    for package in required_packages:
        try:
            __import__(package)
            print_status(f"Package {package} is installed", True)
        except ImportError:
            missing.append(package)
            print_status(f"Package {package} is missing", False)
    
    return len(missing) == 0

def check_gpio():
    """Check GPIO access."""
    try:
        import RPi.GPIO as GPIO
        GPIO.setmode(GPIO.BCM)
        GPIO.setup(18, GPIO.OUT)  # Test pin
        GPIO.output(18, GPIO.HIGH)
        time.sleep(0.1)
        GPIO.output(18, GPIO.LOW)
        GPIO.cleanup()
        print_status("GPIO access working", True)
        return True
    except Exception as e:
        print_status(f"GPIO access failed: {str(e)}", False)
        return False

def check_spi():
    """Check SPI interface."""
    try:
        import spidev
        spi = spidev.SpiDev()
        spi.open(0, 0)
        spi.max_speed_hz = 1000000
        spi.close()
        print_status("SPI interface working", True)
        return True
    except Exception as e:
        print_status(f"SPI interface failed: {str(e)}", False)
        return False

def check_directories():
    """Check if all required directories exist."""
    required_dirs = [
        '/home/pi/firmware',
        '/home/pi/firmware/bin',
        '/home/pi/firmware/drivers',
        '/home/pi/firmware/drivers/input',
        '/home/pi/firmware/drivers/leds'
    ]
    
    missing = []
    for dir_path in required_dirs:
        if os.path.isdir(dir_path):
            print_status(f"Directory {dir_path} exists", True)
        else:
            missing.append(dir_path)
            print_status(f"Directory {dir_path} missing", False)
    
    return len(missing) == 0

def check_services():
    """Check if required services are running."""
    services = ['hackpack-input', 'hackpack-leds']
    
    for service in services:
        result = os.system(f'systemctl is-active --quiet {service}')
        if result == 0:
            print_status(f"Service {service} is running", True)
        else:
            print_status(f"Service {service} is not running", False)
            return False
    return True

def main():
    """Run all verification checks."""
    print_status("Starting HackPack v4 core verification")
    
    # Track overall success
    success = True
    
    # Run checks
    checks = [
        ("Package imports", check_imports),
        ("GPIO access", check_gpio),
        ("SPI interface", check_spi),
        ("Directory structure", check_directories),
        ("System services", check_services)
    ]
    
    for name, check in checks:
        print_status(f"\nChecking {name}...")
        if not check():
            success = False
    
    # Print final status
    if success:
        print_status("\nAll core components working! 🎉", True)
    else:
        print_status("\nSome components failed! Please check errors above.", False)
    
    return 0 if success else 1

if __name__ == "__main__":
    sys.exit(main())
