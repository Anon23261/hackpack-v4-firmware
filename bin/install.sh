#!/bin/bash

# Progress tracking
CURRENT_STEP=1
TOTAL_STEPS=6

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Print functions
print_message() {
    printf "${2}${1}${NC}"
}

print_error() {
    echo -e "${RED}[ERROR] $1${NC}"
    exit 1
}

print_success() {
    echo -e "${GREEN}[OK] $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}[WARN] $1${NC}"
}

print_step() {
    echo -e "${BLUE}[STEP] $1/$TOTAL_STEPS: $2${NC}"
}

show_progress() {
    echo -n "["
    for ((i=1; i<=CURRENT_STEP; i++)); do echo -n "="; done
    for ((i=CURRENT_STEP+1; i<=TOTAL_STEPS; i++)); do echo -n " "; done
    echo "] $((CURRENT_STEP * 100 / TOTAL_STEPS))%"
    CURRENT_STEP=$((CURRENT_STEP + 1))
}

# Check command exists
check_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        print_error "Command not found: $1"
    fi
}

# Test mode
TEST_MODE=false
if [ "$1" = "--test" ]; then
    TEST_MODE=true
    print_warning "Running in test mode - skipping hardware checks"
fi

# System checks
check_system() {
    print_step "1" "Checking system requirements"
    
    if [ "$TEST_MODE" != "true" ]; then
        if [ ! -f /proc/cpuinfo ]; then
            print_error "Cannot access /proc/cpuinfo"
        fi

        model=$(cat /proc/cpuinfo | grep Model | cut -d ':' -f 2 | tr -d ' ')
        case "$model" in
            *"ZeroW"*|*"Zero2W"*)
                print_success "Compatible Pi model detected: $model"
                ;;
            *)
                print_error "This firmware only supports Pi Zero W and Zero 2W (detected: $model)"
                ;;
        esac
    else
        print_success "Test mode - skipping Pi model check"
    fi
    
    if [ "$EUID" -ne 0 ]; then
        print_error "Please run as root"
    fi
    
    print_success "System requirements met"
    show_progress
}

# Main
check_system
