#!/bin/bash
# HackPack v4 Firmware Installer
# For Raspberry Pi Zero W and Zero 2W

# Basic setup
CURRENT_STEP=1
TOTAL_STEPS=6

# Simple colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Basic print function
print_message() {
    printf "%b%s%b" "$2" "$1" "$NC"
}

# Error handling
print_error() {
    print_message "[ERROR] $1\n" "$RED"
    exit 1
}

# Success messages
print_success() {
    print_message "[OK] $1\n" "$GREEN"
}

# Warning messages
print_warning() {
    print_message "[WARN] $1\n" "$YELLOW"
}

# Step messages
print_step() {
    print_message "[STEP] $1/$TOTAL_STEPS: $2\n" "$BLUE"
}

# Progress bar
show_progress() {
    printf "["
    i=1
    while [ $i -le $TOTAL_STEPS ]; do
        if [ $i -le $CURRENT_STEP ]; then
            printf "="
        else
            printf " "
        fi
        i=$((i + 1))
    done
    printf "] %d%%\n" "$((CURRENT_STEP * 100 / TOTAL_STEPS))"
    CURRENT_STEP=$((CURRENT_STEP + 1))
}

# Command check
check_command() {
    command -v "$1" >/dev/null 2>&1 || print_error "Command not found: $1"
}

# Test mode
TEST_MODE=false
[ "$1" = "--test" ] && TEST_MODE=true && print_warning "Test mode enabled"

# System check
check_system() {
    print_step "1" "System check"
    
    # Root check
    [ "$EUID" -ne 0 ] && print_error "Please run as root"
    
    # Hardware check
    if [ "$TEST_MODE" != "true" ]; then
        [ ! -f /proc/cpuinfo ] && print_error "Cannot access /proc/cpuinfo"
        model=$(grep Model /proc/cpuinfo | cut -d ':' -f 2 | tr -d ' ')
        case "$model" in
            *"ZeroW"*|*"Zero2W"*) print_success "Found Pi $model" ;;
            *) print_error "Requires Pi Zero W/2W (found: $model)" ;;
        esac
    fi
    
    print_success "System check passed"
    show_progress
}

# Run checks
check_system

