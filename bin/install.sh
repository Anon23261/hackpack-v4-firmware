

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
}

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
sudo apt-get install --no-install-recommends -y git chromium-browser python3-pip python3-setuptools

# Install Node.js using the NodeSource repository
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

# Update npm to latest version
sudo npm install -g npm@latest

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
echo "(4 of 4) Optional games and input..."
echo ""
echo "--------------------------------------------------"
echo ""
sudo apt-get install --no-install-recommends -y micropolis
sudo apt-get install --no-install-recommends -y openttd
sudo cp -r /home/pi/firmware/assets/chocolate-doom/chocolate-* /usr/local/bin/
sudo cp -r /home/pi/firmware/assets/matchbox-keyboard/matchbox-keyboard /usr/local/bin/
mkdir /home/pi/doom
cp /home/pi/firmware/assets/chocolate-doom/DOOM1.WAD /home/pi/doom
cp /home/pi/firmware/assets/chocolate-doom/.chocolate-doom-config /home/pi/doom
cp /home/pi/firmware/assets/chocolate-doom/.chocolate-doom-extra-config /home/pi/doom
sudo apt-get install -y libsdl1.2debian libsdl-image1.2 libsdl-mixer1.2 timidity
sudo apt-get install -y libsdl-mixer1.2-dev libsdl-net1.2 libsdl-net1.2-dev

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