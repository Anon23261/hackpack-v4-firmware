#!/bin/bash
set -e  # Exit on error

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Progress tracking
TOTAL_STEPS=6
CURRENT_STEP=1

# Print colored message
print_message() {
    echo -e "${2}${1}${NC}"
}

# Print error message and exit
print_error() {
    print_message "\n❌ Error: $1" "$RED"
    exit 1
}

# Print success message
print_success() {
    print_message "\n✓ $1" "$GREEN"
}

# Print warning message
print_warning() {
    print_message "\n⚠️  $1" "$YELLOW"
}

# Print step message
print_step() {
    print_message "\n📦 Step $1/$TOTAL_STEPS: $2" "$BLUE"
}

# Show progress
show_progress() {
    local width=50
    local progress=$((CURRENT_STEP * width / TOTAL_STEPS))
    printf "\n[%-${width}s] %d%%\n" "$(printf "%${progress}s" | tr ' ' '=')" $((CURRENT_STEP * 100 / TOTAL_STEPS))
    ((CURRENT_STEP++))
}

# Check command exists
check_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        print_error "Required command '$1' not found"
    fi
}

# Test mode flag
TEST_MODE=false
if [[ "$1" == "--test" ]]; then
    TEST_MODE=true
    print_warning "Running in test mode - skipping hardware checks"
    
    # Create pi user if in test mode
    if ! id -u pi > /dev/null 2>&1; then
        useradd -m -s /bin/bash pi
        print_success "Created pi user"
    fi
fi

# System checks
check_system() {
    print_step "1" "Checking system requirements"
    
    if [ "$TEST_MODE" != "true" ]; then
        # Check if running on Raspberry Pi
        if [ ! -f /proc/cpuinfo ]; then
            print_error "Cannot access /proc/cpuinfo"
        fi

        # Check Pi model
        local model=$(cat /proc/cpuinfo | grep Model | cut -d ':' -f 2 | tr -d ' ')
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
    
    # Check root
    if [ "$EUID" -ne 0 ]; then
        print_error "Please run as root (use sudo)"
    fi
    
    # Check required commands
    local required_commands=("python3" "pip3" "git" "systemctl")
    for cmd in "${required_commands[@]}"; do
        check_command "$cmd"
    done

    # Check Python version
    local python_version=$(python3 -c 'import sys; print("{}.{}".format(sys.version_info.major, sys.version_info.minor))')
    if [ "$(echo "$python_version >= 3.7" | bc)" -eq 0 ]; then
        print_error "Python 3.7 or higher required (found: $python_version)"
    fi

    # Check available disk space
    local required_space=500000  # 500MB in KB
    local available_space=$(df -k /home/pi | awk 'NR==2 {print $4}')
    if [ "$available_space" -lt "$required_space" ]; then
        print_error "Insufficient disk space. Required: 500MB, Available: $((available_space/1024))MB"
    fi

    print_success "System requirements met"
    show_progress
}

# Backup function
backup_config() {
    print_step "2" "Backing up system configuration"
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_dir="/home/pi/firmware_backup_${timestamp}"
    
    # Ensure /home/pi exists
    if [ ! -d "/home/pi" ]; then
        print_warning "Creating /home/pi directory..."
        if ! mkdir -p "/home/pi"; then
            print_error "Failed to create /home/pi directory"
        fi
        chown pi:pi "/home/pi"
    fi
    
    print_message "Creating backup in $backup_dir" "$YELLOW"
    
    if ! mkdir -p "$backup_dir"; then
        print_warning "Attempting backup in /tmp..."
        backup_dir="/tmp/firmware_backup_${timestamp}"
        if ! mkdir -p "$backup_dir"; then
            print_error "Could not create backup directory"
        fi
    fi
    
    # Backup system files
    for file in config.txt cmdline.txt; do
        if [ -f "/boot/$file" ]; then
            if ! cp "/boot/$file" "$backup_dir/"; then
                print_error "Failed to backup $file"
            fi
            print_success "$file backed up"
        else
            print_warning "$file not found in /boot"
        fi
    done
    
    # Set permissions
    chown -R pi:pi "$backup_dir"
    chmod -R 644 "$backup_dir"/*
    
    print_success "Backup completed in $backup_dir"
    print_message "To restore: sudo cp $backup_dir/* /boot/" "$YELLOW"
    show_progress
}

# Install dependencies
install_dependencies() {
    print_step "3" "Installing system dependencies"
    
    # Update package list
    print_message "Updating package list..." "$YELLOW"
    if ! apt-get update; then
        print_error "Failed to update package list"
    fi
    
    # Install required packages
    local packages=(
        "python3-pip"
        "python3-venv"
        "python3-dev"
        "git"
        "build-essential"
        "libffi-dev"
        "libssl-dev"
        "netcat-openbsd"
        "bc"
        "raspi-config"
    )
    
    for package in "${packages[@]}"; do
        print_message "Installing $package..." "$YELLOW"
        if ! apt-get install -y "$package"; then
            print_warning "Failed to install $package"
        fi
    done
    
    # Enable SPI interface
    print_message "Enabling SPI interface..." "$YELLOW"
    raspi-config nonint do_spi 0
    
    # Add pi user to gpio group
    usermod -a -G gpio pi
    
    print_success "Dependencies installed"
    show_progress
}

# Setup Python environment
setup_python() {
    print_step "4" "Setting up Python environment"
    
    # Create virtual environment
    print_message "Creating virtual environment..." "$YELLOW"
    if [ -d "/home/pi/firmware/venv" ]; then
        print_warning "Removing existing virtual environment..."
        rm -rf "/home/pi/firmware/venv"
    fi
    
    if ! python3 -m venv "/home/pi/firmware/venv"; then
        print_error "Failed to create virtual environment"
    fi
    
    # Activate virtual environment
    source "/home/pi/firmware/venv/bin/activate"
    
    # Upgrade pip
    print_message "Upgrading pip..." "$YELLOW"
    if ! pip install --upgrade pip; then
        print_warning "Failed to upgrade pip"
    fi
    
    # Install requirements one by one
    print_message "Installing Python packages..." "$YELLOW"
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip comments and empty lines
        if [[ $line =~ ^#.*$ ]] || [[ -z $line ]]; then
            continue
        fi
        
        # Extract package name and version
        package=$(echo "$line" | cut -d'=' -f1)
        print_message "Installing $package..." "$YELLOW"
        
        if ! pip install "$line" --no-deps; then
            print_warning "Failed to install $package, trying with --ignore-installed"
            if ! pip install "$line" --no-deps --ignore-installed; then
                print_warning "Could not install $package, continuing anyway"
            fi
        fi
    done < requirements.txt
    
    print_message "Installing dependencies..." "$YELLOW"
    pip install --upgrade pip setuptools wheel
    
    print_success "Python environment ready"
    show_progress
}

# Install firmware
install_firmware() {
    print_step "5" "Installing firmware files"
    
    local firmware_dir="/home/pi/firmware"
    
    # Backup existing firmware if present
    if [ -d "$firmware_dir" ]; then
        local backup_name="firmware_backup_$(date +%Y%m%d_%H%M%S)"
        print_warning "Existing firmware found, backing up to $backup_name"
        mv "$firmware_dir" "/home/pi/$backup_name"
    fi
    
    # Create fresh firmware directory
    mkdir -p "$firmware_dir"
    
    # Copy firmware files, excluding development files
    print_message "Copying firmware files..." "$YELLOW"
    rsync -av \
        --exclude 'tests/' \
        --exclude 'mock_hardware/' \
        --exclude '.git*' \
        --exclude 'venv/' \
        --exclude '.pytest_cache/' \
        --exclude '__pycache__/' \
        --exclude '*.pyc' \
        --exclude 'requirements.dev.txt' \
        --exclude '.coverage' \
        --exclude 'htmlcov/' \
        --exclude '.tox/' \
        . "$firmware_dir/"
    
    # Set correct permissions
    chown -R pi:pi "$firmware_dir"
    chmod -R 755 "$firmware_dir/bin"
    chmod +x "$firmware_dir/bin/"*.sh
    
    print_success "Firmware files installed"
    show_progress
}

# Setup services
setup_services() {
    print_step "6" "Setting up system services"
    
    # Install service files
    cp bin/system/hackpack-input.service /etc/systemd/system/
    cp bin/system/hackpack-leds.service /etc/systemd/system/
    
    # Reload systemd
    systemctl daemon-reload
    
    # Enable services
    systemctl enable hackpack-input.service
    systemctl enable hackpack-leds.service
    
    # Start services
    systemctl start hackpack-input.service
    systemctl start hackpack-leds.service
    
    print_success "Services installed and started"
    show_progress
}

# Verify installation
verify_installation() {
    print_step "7" "Verifying installation"
    
    # Check Python environment
    print_message "Checking Python environment..." "$YELLOW"
    source "/home/pi/firmware/venv/bin/activate"
    if ! python3 -c "import RPi.GPIO; import spidev; import fastapi; import rich"; then
        print_error "Required Python packages not properly installed"
    fi
    
    # Check services
    print_message "Checking system services..." "$YELLOW"
    for service in hackpack-input hackpack-leds; do
        if ! systemctl is-active --quiet "$service"; then
            print_error "Service $service is not running"
        fi
        print_success "Service $service is running"
    done
    
    # Check hardware interfaces
    print_message "Checking hardware interfaces..." "$YELLOW"
    if ! raspi-config nonint get_spi | grep -q "0"; then
        print_error "SPI interface not enabled"
    fi
    
    # Check GPIO permissions
    if ! groups pi | grep -q "gpio"; then
        print_error "User 'pi' not in gpio group"
    fi
    
    # Check LED functionality
    print_message "Testing LED system..." "$YELLOW"
    if ! timeout 5s python3 -c 'from drivers.leds.light_client import LightClient; client=LightClient(); client.set_color(255,255,255); import time; time.sleep(1); client.set_color(0,0,0)' 2>/dev/null; then
        print_warning "LED test failed - please check LED connections"
    fi
    
    print_success "Installation verified"
    show_progress
}

# Main installation
main() {
    print_message "\n🌈 HackPack v4 Firmware Installer" "$BOLD"
    print_message "This script will install the HackPack v4 firmware for Raspberry Pi Zero W/2W\n" "$YELLOW"
    
    # Perform installation steps
    check_system
    backup_config
    install_dependencies
    setup_python
    install_firmware
    setup_services
    verify_installation
    
    print_success "🎉 Installation completed successfully!"
    
    # Final instructions
    print_message "\nImportant Next Steps:" "$BLUE"
    print_message "1. Reboot your Pi:   sudo reboot" "$YELLOW"
    print_message "2. Watch LED pattern at startup" "$YELLOW"
    print_message "3. Press A button to launch IPython shell" "$YELLOW"
    print_message "4. Visit https://github.com/yourusername/hackpack-v4-firmware for documentation" "$YELLOW"
}

# Run main installation
main "$@"
