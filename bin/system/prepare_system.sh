#!/bin/bash
set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if running on supported hardware
check_hardware() {
    local model=$(tr -d '\0' < /proc/device-tree/model)
    if [[ $model == *"Zero W"* ]] || [[ $model == *"Zero 2 W"* ]]; then
        echo -e "${GREEN}✓ Running on supported hardware: $model${NC}"
        return 0
    else
        echo -e "${RED}✗ Unsupported hardware: $model${NC}"
        echo -e "${YELLOW}This firmware only supports Raspberry Pi Zero W and Zero 2 W${NC}"
        return 1
    fi
}

# Function to check system requirements
check_system_requirements() {
    echo -e "\n${YELLOW}Checking system requirements...${NC}"
    
    # Check Python version
    if command -v python3 >/dev/null 2>&1; then
        local python_version=$(python3 --version)
        echo -e "${GREEN}✓ Python 3 installed: $python_version${NC}"
    else
        echo -e "${RED}✗ Python 3 not found${NC}"
        return 1
    fi
    
    # Check pip
    if command -v pip3 >/dev/null 2>&1; then
        local pip_version=$(pip3 --version)
        echo -e "${GREEN}✓ pip3 installed: $pip_version${NC}"
    else
        echo -e "${RED}✗ pip3 not found${NC}"
        return 1
    fi
    
    # Check required system packages
    local required_packages=("git" "python3-dev" "python3-pip" "python3-venv" "libopenjp2-7" "libtiff5")
    local missing_packages=()
    
    for package in "${required_packages[@]}"; do
        if ! dpkg -l | grep -q "^ii  $package "; then
            missing_packages+=("$package")
        fi
    done
    
    if [ ${#missing_packages[@]} -eq 0 ]; then
        echo -e "${GREEN}✓ All required system packages are installed${NC}"
    else
        echo -e "${RED}✗ Missing required packages: ${missing_packages[*]}${NC}"
        return 1
    fi
    
    return 0
}

# Function to prepare system
prepare_system() {
    echo -e "\n${YELLOW}Preparing system...${NC}"
    
    # Update package list
    echo -e "${YELLOW}Updating package list...${NC}"
    apt-get update
    
    # Install required packages
    echo -e "${YELLOW}Installing required packages...${NC}"
    apt-get install -y git python3-dev python3-pip python3-venv libopenjp2-7 libtiff5
    
    # Create virtual environment
    echo -e "${YELLOW}Creating Python virtual environment...${NC}"
    python3 -m venv /home/pi/firmware/venv
    
    # Clean up
    echo -e "${YELLOW}Cleaning up...${NC}"
    apt-get clean
    rm -rf /var/lib/apt/lists/*
    
    echo -e "${GREEN}✓ System preparation complete${NC}"
    return 0
}

# Main execution
main() {
    # Check if script is run as root
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}Error: Please run as root (use sudo)${NC}"
        exit 1
    fi
    
    # Check hardware compatibility
    if ! check_hardware; then
        exit 1
    fi
    
    # Check system requirements
    if ! check_system_requirements; then
        echo -e "${YELLOW}Attempting to fix missing requirements...${NC}"
        if ! prepare_system; then
            echo -e "${RED}Failed to prepare system${NC}"
            exit 1
        fi
    fi
    
    echo -e "\n${GREEN}System is ready for HackPack v4 firmware installation${NC}"
    return 0
}

main "$@"
