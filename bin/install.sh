

#!/bin/bash
set -e  # Exit on error

# Test mode flag
TEST_MODE=false
if [[ "$1" == "--test" ]]; then
    TEST_MODE=true
    echo "Running in test mode..."
fi

# Safety checks and backup function
backup_config() {
    local backup_dir="/home/pi/firmware_backup_$(date +%Y%m%d_%H%M%S)"
    echo "Creating backup in $backup_dir"
    if ! mkdir -p "$backup_dir"; then
        echo "Error: Failed to create backup directory"
        return 1
    fi
    
    # Backup important system files
    if [ -f /boot/config.txt ]; then
        if ! cp /boot/config.txt "$backup_dir/"; then
            echo "Error: Failed to backup config.txt"
            return 1
        fi
    fi
    if [ -f /boot/cmdline.txt ]; then
        if ! cp /boot/cmdline.txt "$backup_dir/"; then
            echo "Error: Failed to backup cmdline.txt"
            return 1
        fi
    fi
    
    echo "Backup completed. To restore, use: sudo cp $backup_dir/* /boot/"
    return 0
}

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: Please run as root (use sudo)"
    exit 1
fi

# Check if running on a Raspberry Pi (skip in test mode)
if [ "$TEST_MODE" != "true" ]; then
    if [ ! -f /proc/cpuinfo ]; then
        echo "Error: Cannot access /proc/cpuinfo"
        exit 1
    fi

    if ! grep -q "Raspberry Pi" /proc/cpuinfo; then
        echo "Error: This script must be run on a Raspberry Pi"
        exit 1
    fi
fi

# Check if firmware directory exists (create in test mode)
if [ "$TEST_MODE" == "true" ]; then
    mkdir -p /home/pi/firmware/bin
    mkdir -p /home/pi/firmware/drivers/bin
    mkdir -p /home/pi/firmware/cli/bin
    mkdir -p /home/pi/firmware/assets/images
    mkdir -p /home/pi/firmware/assets/config
    
    # Create test detect_model.sh
    echo '#!/bin/bash
echo "pi0-2w"' > /home/pi/firmware/bin/detect_model.sh
    chmod +x /home/pi/firmware/bin/detect_model.sh
    
    # Create test requirements.txt
    echo 'requests==2.31.0
flask==3.0.0' > /home/pi/firmware/requirements.txt
    
    # Create test driver install script
    echo '#!/bin/bash
echo "Driver install test"' > /home/pi/firmware/drivers/bin/install.sh
    chmod +x /home/pi/firmware/drivers/bin/install.sh
    
    # Create test CLI install script
    echo '#!/bin/bash
echo "CLI install test"' > /home/pi/firmware/cli/bin/install.sh
    chmod +x /home/pi/firmware/cli/bin/install.sh
else
    if [ ! -d /home/pi/firmware ]; then
        echo "Error: Firmware directory not found at /home/pi/firmware"
        exit 1
    fi
fi

# Make detect_model.sh executable
if [ ! -f /home/pi/firmware/bin/detect_model.sh ]; then
    echo "Error: detect_model.sh not found"
    exit 1
fi

if ! chmod +x /home/pi/firmware/bin/detect_model.sh; then
    echo "Error: Failed to make detect_model.sh executable"
    exit 1
fi

# Detect Pi model
PI_MODEL=$(/home/pi/firmware/bin/detect_model.sh)
if [ $? -ne 0 ]; then
    echo "Error: Failed to detect Raspberry Pi model"
    exit 1
fi

if [ "$PI_MODEL" = "unknown" ]; then
    echo "Error: Unsupported Raspberry Pi model detected"
    echo "This firmware only supports Pi Zero W and Pi Zero 2W"
    exit 1
fi

echo "Detected Raspberry Pi model: $PI_MODEL"

# Create backup before proceeding
echo "Creating backup of current configuration..."
backup_config

# Confirm before proceeding
echo ""
echo "WARNING: This will install Hackpack v4 firmware for $PI_MODEL"
echo "A backup of your current configuration has been created"
read -p "Do you want to proceed? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation cancelled"
    exit 1
fi

# Install basic system dependencies
echo ""
echo "--------------------------------------------------"
echo ""
echo "(1 of 5) Installing system basics for $PI_MODEL..."
echo ""
echo "--------------------------------------------------"
echo ""

sudo mkdir -p /home/pi/hp_tmp

#sudo touch /home/pi/hp_tmp/.hp_storage_
#sudo chown -R pi:pi /home/pi/hp_tmp/.hp_storage_

#sudo touch /home/pi/hp_tmp/.authtoken
#sudo chown -R pi:pi /home/pi/hp_tmp/.authtoken

# Update package lists and install required packages
echo "Updating package lists..."
if ! sudo apt-get update; then
    echo "Error: Failed to update package lists"
    exit 1
fi

echo "Installing system packages..."
if ! sudo apt-get install --no-install-recommends -y \
    git \
    python3-pip \
    python3-setuptools \
    python3-venv \
    python3-dev \
    build-essential \
    libssl-dev \
    libffi-dev \
    nmap \
    wireshark \
    tcpdump \
    sqlite3 \
    nginx \
    screen \
    tmux; then
    echo "Error: Failed to install system packages"
    exit 1
fi

# Try to install netcat
echo "Installing netcat..."
if ! sudo apt-get install -y netcat-traditional; then
    echo "Trying alternative netcat package..."
    if ! sudo apt-get install -y netcat-openbsd; then
        echo "Warning: Could not install netcat. Continuing anyway..."
    fi
fi

# Install Python security and development packages
echo "Installing Python packages..."

# Create a temporary requirements file
cat > /tmp/requirements.txt << 'EOL'
requests
flask
fastapi
uvicorn
sqlalchemy
python-dotenv
pwntools
scapy
cryptography
pytest
black
pylint
jupyter
EOL

# Install packages using pip with --break-system-packages
if ! sudo pip3 install --no-cache-dir --break-system-packages -r /tmp/requirements.txt; then
    echo "Error: Failed to install Python packages"
    rm /tmp/requirements.txt
    exit 1
fi

# Clean up
rm /tmp/requirements.txt

# Run Driver install script

echo ""
echo "--------------------------------------------------"
echo ""
echo "(2 of 5) Starting Hackpack Driver install..."
echo ""
echo "--------------------------------------------------"
echo ""

sudo bash /home/pi/firmware/drivers/bin/install.sh

# Run CLI install script

echo ""
echo "--------------------------------------------------"
echo ""
echo "(3 of 5) Starting Hackpack CLI install..."
echo ""
echo "--------------------------------------------------"
echo ""

sudo bash /home/pi/firmware/cli/bin/install.sh

# Run Kiosk install

echo ""
echo "--------------------------------------------------"
echo ""
echo "(4 of 5) Setting up development environment..."
echo ""
echo "--------------------------------------------------"
echo ""

# Create Python virtual environment
echo "Creating Python virtual environment..."
if [ -d /home/pi/venv ]; then
    echo "Removing existing virtual environment..."
    rm -rf /home/pi/venv
fi
if ! python3 -m venv /home/pi/venv; then
    echo "Error: Failed to create virtual environment"
    exit 1
fi

# Add venv activation to bashrc if not already present
if ! grep -q "source /home/pi/venv/bin/activate" /home/pi/.bashrc; then
    if ! echo 'source /home/pi/venv/bin/activate' >> /home/pi/.bashrc; then
        echo "Error: Failed to update .bashrc"
        exit 1
    fi
fi

# Set up development directories
echo "Creating project directories..."
for dir in "/home/pi/projects" "/home/pi/projects/payloads" "/home/pi/projects/api"; do
    if ! mkdir -p "$dir"; then
        echo "Error: Failed to create directory $dir"
        exit 1
    fi
done

echo ""
echo "--------------------------------------------------"
echo ""
echo "(5 of 5) Installing Python development packages..."
echo ""
echo "--------------------------------------------------"
echo ""

# Activate virtual environment and install packages
if [ ! -f /home/pi/venv/bin/activate ]; then
    echo "Error: Virtual environment activation script not found"
    exit 1
fi

# We need to source in a subshell to avoid affecting the main script
echo "Installing Python packages..."
if ! (source /home/pi/venv/bin/activate && pip install -r /home/pi/firmware/requirements.txt); then
    echo "Error: Failed to install Python packages"
    exit 1
fi

# Create helpful scripts
cat > /home/pi/projects/scan_network.py << 'EOL'
#!/usr/bin/env python3
from scapy.all import ARP, Ether, srp
import sys

def scan(ip_range):
    arp = ARP(pdst=ip_range)
    ether = Ether(dst="ff:ff:ff:ff:ff:ff")
    packet = ether/arp
    result = srp(packet, timeout=3, verbose=0)[0]
    devices = []
    for sent, received in result:
        devices.append({'ip': received.psrc, 'mac': received.hwsrc})
    return devices

if __name__ == "__main__":
    ip_range = sys.argv[1] if len(sys.argv) > 1 else "192.168.1.0/24"
    print(f"Scanning network {ip_range}...")
    devices = scan(ip_range)
    print("\nDevices found:")
    print("IP" + " "*18 + "MAC")
    print("-" * 40)
    for device in devices:
        print(f"{device['ip']:20} {device['mac']}")
EOL

if ! chmod +x /home/pi/projects/scan_network.py; then
    echo "Warning: Failed to make scan_network.py executable"
fi

# Create example API server
cat > /home/pi/projects/api/example_server.py << 'EOL'
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import uvicorn

class Device(BaseModel):
    name: str
    ip: str
    mac: str

app = FastAPI(title="IoT Security API")

@app.get("/")
async def read_root():
    return {"message": "Welcome to IoT Security API"}

@app.get("/devices")
async def get_devices():
    return {"devices": []}

@app.post("/devices")
async def add_device(device: Device):
    return device

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
EOL

if ! chmod +x /home/pi/projects/api/example_server.py; then
    echo "Warning: Failed to make example_server.py executable"
fi

# Create README with instructions
cat > /home/pi/projects/README.md << 'EOL'
# IoT Security and Development Environment

## Available Tools
- Network scanning: nmap, wireshark, tcpdump
- Security: pwntools, scapy, cryptography
- API Development: flask, fastapi, uvicorn
- Database: sqlite3, sqlalchemy
- Code Quality: black, pylint, pytest

## Quick Start
1. Network scan: `sudo python3 scan_network.py`
2. Start API server: `cd api && python3 example_server.py`
3. Run tests: `pytest`
4. Format code: `black .`

## Virtual Environment
Activated automatically on login, or manually:
`source ~/venv/bin/activate`

## Project Structure
- ~/projects/iot/: IoT-related projects
- ~/projects/api/: API servers and clients
- ~/projects/security/: Security tools and scripts
EOL

echo ""
echo "--------------------------------------------------"
echo ""
echo "(5 of 5) Final steps and aesthetics"
echo ""
echo "--------------------------------------------------"
echo ""
# Set proper ownership and permissions
echo "Setting proper ownership and permissions..."
if ! sudo chown -R pi:pi /home/pi/; then
    echo "Warning: Failed to set ownership of /home/pi"
fi

if ! chmod -R 755 /home/pi/firmware/bin/; then
    echo "Warning: Failed to set permissions on firmware binaries"
fi

# Set wallpaper & aesthetics
if [ -f /home/pi/firmware/assets/images/wallpaper.png ]; then
    echo "Setting wallpaper..."
    if ! pcmanfm --set-wallpaper /home/pi/firmware/assets/images/wallpaper.png; then
        echo "Warning: Failed to set wallpaper"
    fi
fi

if [ -d /home/pi/firmware/assets/config ]; then
    echo "Copying config files..."
    if ! sudo cp -r /home/pi/firmware/assets/config /home/pi/.config; then
        echo "Warning: Failed to copy config files"
    fi
fi

# Cleanup
echo "Cleaning up unnecessary packages..."
if ! sudo apt-get purge -y libreoffice wolfram-engine sonic-pi scratch; then
    echo "Warning: Failed to remove some packages"
fi

if ! sudo apt-get -y autoremove; then
    echo "Warning: Failed to autoremove packages"
fi

echo ""
echo "--------------------------------------------------"
echo ""
echo "Finished installing Hackpack v4. Rebooting..."
echo ""
echo "--------------------------------------------------"
echo ""

sudo shutdown -r now