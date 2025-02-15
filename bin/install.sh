

#!/bin/bash

# Safety checks and backup function
backup_config() {
    local backup_dir="/home/pi/firmware_backup_$(date +%Y%m%d_%H%M%S)"
    echo "Creating backup in $backup_dir"
    mkdir -p "$backup_dir"
    
    # Backup important system files
    if [ -f /boot/config.txt ]; then
        cp /boot/config.txt "$backup_dir/"
    fi
    if [ -f /boot/cmdline.txt ]; then
        cp /boot/cmdline.txt "$backup_dir/"
    fi
    
    echo "Backup completed. To restore, use: sudo cp $backup_dir/* /boot/"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (use sudo)"
    exit 1
fi

# Check if we're running on a Raspberry Pi
if ! grep -q "Raspberry Pi" /proc/cpuinfo; then
    echo "This script must be run on a Raspberry Pi"
    exit 1
fi

# Make detect_model.sh executable
chmod +x /home/pi/firmware/bin/detect_model.sh

# Detect Pi model
PI_MODEL=$(/home/pi/firmware/bin/detect_model.sh)

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
sudo apt-get update
sudo apt-get install --no-install-recommends -y \
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
    netcat \
    sqlite3 \
    nginx \
    screen \
    tmux

# Install Python security and development packages
sudo pip3 install --no-cache-dir \
    requests \
    flask \
    fastapi \
    uvicorn \
    sqlalchemy \
    python-dotenv \
    pwntools \
    scapy \
    cryptography \
    pytest \
    black \
    pylint \
    jupyter

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
python3 -m venv /home/pi/venv
echo 'source /home/pi/venv/bin/activate' >> /home/pi/.bashrc

# Set up development directories
mkdir -p /home/pi/projects
mkdir -p /home/pi/projects/payloads

echo ""
echo "--------------------------------------------------"
echo ""
echo "(5 of 5) Installing Python development packages..."
echo ""
echo "--------------------------------------------------"
echo ""

# Activate virtual environment and install packages
source /home/pi/venv/bin/activate
pip install -r /home/pi/firmware/requirements.txt

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

chmod +x /home/pi/projects/scan_network.py

# Create example API server
cat > /home/pi/projects/api/example_server.py << 'EOL'
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import uvicorn

app = FastAPI(title="IoT Security API")

class Device(BaseModel):
    name: str
    ip: str
    status: str

devices = []

@app.get("/")
async def read_root():
    return {"status": "online", "message": "IoT Security API"}

@app.get("/devices")
async def get_devices():
    return devices

@app.post("/devices")
async def add_device(device: Device):
    devices.append(device)
    return device

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
EOL

chmod +x /home/pi/projects/api/example_server.py

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
# Own all the things!
sudo chown -R pi:pi /home/pi/

# Execute all the bins!
chmod -R 755 /home/pi/firmware/bin/

# Set wallpaper & aesthetics
pcmanfm --set-wallpaper /home/pi/firmware/assets/images/wallpaper.png
sudo cp -r /home/pi/firmware/assets/config /home/pi/.config

# Cleanup
sudo apt-get purge -y libreoffice wolfram-engine sonic-pi scratch
sudo apt-get -y autoremove

echo ""
echo "--------------------------------------------------"
echo ""
echo "Finished installing Hackpack v4. Rebooting..."
echo ""
echo "--------------------------------------------------"
echo ""

sudo shutdown -r now