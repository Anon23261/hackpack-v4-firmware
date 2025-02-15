#!/bin/bash

# Initialize variables
CURRENT_STEP=1
TOTAL_STEPS=6
TEST_MODE=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Message functions
msg() {
    printf "${2}${1}${NC}\n"
}

error() {
    msg "[ERROR] $1" "$RED"
    exit 1
}

success() {
    msg "[OK] $1" "$GREEN"
}

warn() {
    msg "[WARN] $1" "$YELLOW"
}

step() {
    msg "[STEP] $1/$TOTAL_STEPS: $2" "$BLUE"
}

# Progress display
progress() {
    local dots
    dots=""
    i=1
    while [ "$i" -le "$CURRENT_STEP" ]
    do
        dots="$dots="
        i=$((i + 1))
    done
    while [ "$i" -le "$TOTAL_STEPS" ]
    do
        dots="$dots "
        i=$((i + 1))
    done
    msg "[$dots] $((CURRENT_STEP * 100 / TOTAL_STEPS))%" "$BLUE"
    CURRENT_STEP=$((CURRENT_STEP + 1))
}

# Check for command
check_cmd() {
    command -v "$1" >/dev/null 2>&1 || error "Required command not found: $1"
}

# System validation
check_system() {
    step "1" "System check"
    
    # Root check
    [ "$(id -u)" -ne 0 ] && error "Please run as root"
    
    # Hardware check (skip in test mode)
    if [ "$TEST_MODE" -eq 0 ]; then
        [ ! -f /proc/cpuinfo ] && error "Cannot access /proc/cpuinfo"
        MODEL=$(grep Model /proc/cpuinfo | cut -d ':' -f 2 | tr -d ' ')
        case "$MODEL" in
            *"ZeroW"*|*"Zero2W"*) 
                success "Found compatible Pi model: $MODEL"
                ;;
            *) 
                error "This firmware requires Pi Zero W/2W (found: $MODEL)"
                ;;
        esac
    else
        warn "Test mode: skipping hardware check"
    fi
    
    success "System check passed"
    progress
}

# Parse arguments
[ "$1" = "--test" ] && TEST_MODE=1

# Run system check
check_system

