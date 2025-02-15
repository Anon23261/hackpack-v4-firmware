#!/bin/sh
# HackPack v4 Firmware Installer for Pi Zero W/2W

# Variables
CURRENT_STEP=1
TOTAL_STEPS=6
TEST_MODE=0

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

warn() {
    msg "[WARN] $1" "$YELLOW"
}

info() {
    msg "[INFO] $1" "$BLUE"
}

# Simple progress bar
progress() {
    printf "[" >&2
    i=1
    while [ $i -le $TOTAL_STEPS ]; do
        if [ $i -le $CURRENT_STEP ]; then
            printf "#" >&2
        else
            printf "-" >&2
        fi
        i=$(($i + 1))
    done
    printf "] %d%%\n" $(($CURRENT_STEP * 100 / $TOTAL_STEPS)) >&2
    CURRENT_STEP=$(($CURRENT_STEP + 1))
}

# Check root
[ $(id -u) -ne 0 ] && error "Must run as root"

# Handle test mode
[ "$1" = "--test" ] && TEST_MODE=1 && warn "Running in test mode"

# System check
info "Checking system requirements..."

if [ $TEST_MODE -eq 0 ]; then
    if [ ! -f /proc/cpuinfo ]; then
        error "Cannot access /proc/cpuinfo"
    fi
    
    MODEL=$(grep Model /proc/cpuinfo | cut -d: -f2 | tr -d " ")
    case "$MODEL" in
        *"ZeroW"*|*"Zero2W"*)
            ok "Found Pi $MODEL"
            ;;
        *)
            error "Requires Pi Zero W/2W (found: $MODEL)"
            ;;
    esac
else
    warn "Skipping hardware check (test mode)"
fi

ok "System check complete"
progress

