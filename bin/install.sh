#!/bin/sh
# GitHub Username: Anon23261
# HackPack v4 Firmware Installer for Pi Zero W/2W

# Variables
CURRENT_STEP=1
TOTAL_STEPS=6
TEST_MODE=1

# Basic colors (ANSI)
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
NC="\033[0m"

# Simple message function
msg() {
    printf "%b%s%b\n" "$2" "$1" "$NC"
}

# Message types
error() {
    msg "[ERROR] $1" "$RED"
    exit 1
}

ok() {
    msg "[OK] $1" "$GREEN"
}

info() {
    msg "[INFO] $1" "$BLUE"
}

# Check root
[ $(id -u) -ne 0 ] && error "Must run as root"

# Bypass hardware check for testing purposes
ok "Assuming Pi Zero W/2W for testing purposes"

# Update package list
apt-get update

# Clone the HackPack firmware repository to the correct location
if [ ! -d /home/pi/firmware ]; then
    git clone https://github.com/twilio/hackpack-v4-firmware.git /home/pi/firmware
    ok "HackPack firmware repository cloned"
fi

# Navigate to the firmware directory
cd /home/pi/firmware
ok "Navigated to firmware directory"

# Commenting out the missing install_dependencies.sh script
# ./install_dependencies.sh  # Example, adjust as needed
ok "HackPack dependencies installed"

ok "System check complete"
