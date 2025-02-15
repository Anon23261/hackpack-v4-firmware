#!/bin/bash
set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check Python packages
check_python_packages() {
    echo -e "\n${YELLOW}Verifying Python packages...${NC}"
    source /home/pi/firmware/venv/bin/activate
    
    # Read requirements.txt and check each package
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip comments and empty lines
        [[ $line =~ ^#.*$ ]] && continue
        [[ -z $line ]] && continue
        
        # Extract package name and version
        package=$(echo "$line" | cut -d'=' -f1)
        version=$(echo "$line" | cut -d'=' -f3)
        
        if pip list | grep -q "^$package "; then
            echo -e "${GREEN}✓ $package installed${NC}"
        else
            echo -e "${RED}✗ $package not installed${NC}"
            return 1
        fi
    done < /home/pi/firmware/requirements.txt
    
    deactivate
    return 0
}

# Function to check hardware interfaces
check_hardware_interfaces() {
    echo -e "\n${YELLOW}Verifying hardware interfaces...${NC}"
    
    # Check SPI
    if [ -e /dev/spidev0.0 ] || [ -e /dev/spidev0.1 ]; then
        echo -e "${GREEN}✓ SPI interface available${NC}"
    else
        echo -e "${RED}✗ SPI interface not available${NC}"
        return 1
    fi
    
    # Check I2C
    if [ -e /dev/i2c-1 ]; then
        echo -e "${GREEN}✓ I2C interface available${NC}"
    else
        echo -e "${RED}✗ I2C interface not available${NC}"
        return 1
    fi
    
    return 0
}

# Function to check system services
check_services() {
    echo -e "\n${YELLOW}Verifying system services...${NC}"
    
    # Check LED service
    if systemctl is-active --quiet hackpack-leds; then
        echo -e "${GREEN}✓ LED service is running${NC}"
    else
        echo -e "${RED}✗ LED service is not running${NC}"
        return 1
    fi
    
    # Check input service
    if systemctl is-active --quiet hackpack-input; then
        echo -e "${GREEN}✓ Input service is running${NC}"
    else
        echo -e "${RED}✗ Input service is not running${NC}"
        return 1
    fi
    
    return 0
}

# Function to run basic functionality tests
test_functionality() {
    echo -e "\n${YELLOW}Testing basic functionality...${NC}"
    
    # Test LED control
    echo -e "Testing LED control..."
    if python3 -c "
from drivers.leds.light_client.lightclient import LightClient
client = LightClient()
client.connect()
client.set_pattern('success')
client.close()
"; then
        echo -e "${GREEN}✓ LED control working${NC}"
    else
        echo -e "${RED}✗ LED control failed${NC}"
        return 1
    fi
    
    # Test input driver
    echo -e "Testing input driver..."
    if python3 -c "
from drivers.input.input_driver import ADC
with ADC(bus=1, channel=0, device=1) as adc:
    value = adc.read()
assert 0 <= value <= 1024
"; then
        echo -e "${GREEN}✓ Input driver working${NC}"
    else
        echo -e "${RED}✗ Input driver failed${NC}"
        return 1
    fi
    
    return 0
}

# Main execution
main() {
    # Check if script is run as root
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}Error: Please run as root (use sudo)${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}HackPack v4 Firmware Installation Verification${NC}"
    
    # Run all checks
    check_python_packages
    check_hardware_interfaces
    check_services
    test_functionality
    
    # Final status
    if [ $? -eq 0 ]; then
        echo -e "\n${GREEN}✓ All checks passed - Installation verified successfully!${NC}"
        echo -e "${YELLOW}Your HackPack v4 is ready to use.${NC}"
        return 0
    else
        echo -e "\n${RED}✗ Some checks failed - Please review the errors above${NC}"
        return 1
    fi
}

main "$@"
