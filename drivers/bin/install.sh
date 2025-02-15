#!/bin/bash

# Function to check if a package is installed
check_package() {
    if ! command -v $1 &> /dev/null; then
        echo "Error: Required package '$1' is not installed"
        return 1
    fi
    return 0
}

# Check for required packages
required_packages=("python3" "pip3" "git")
for package in "${required_packages[@]}"; do
    if ! check_package $package; then
        echo "Please install required packages first:"
        echo "sudo apt-get update && sudo apt-get install -y python3 python3-pip git"
        exit 1
    fi
}

# Detect Pi model
if [ ! -f "/home/pi/firmware/bin/detect_model.sh" ]; then
    echo "Error: detect_model.sh script not found"
    exit 1
fi

PI_MODEL=$(/home/pi/firmware/bin/detect_model.sh)

# Verify we're on a supported model
if [ "$PI_MODEL" != "zero2" ] && [ "$PI_MODEL" != "zerow" ]; then
    echo "Error: Unsupported Raspberry Pi model detected"
    echo "This firmware only supports Pi Zero W and Pi Zero 2W"
    exit 1
fi

# Install Python packages with error checking
echo "Installing Python packages..."
for package in "python-uinput" "RPi.GPIO" "spidev"; do
    echo "Installing $package..."
    if ! sudo pip3 install $package; then
        echo "Error: Failed to install $package"
        exit 1
    fi
done

# Overlay appropriate config.txt based on Pi model
echo ""
echo "Installing Hackpack boot configuration for $PI_MODEL..."
echo ""

if [ "$PI_MODEL" = "zero2" ]; then
    sudo cp /home/pi/firmware/bin/root/boot/config_zero2w.txt /boot/config.txt
    echo "Installed Zero 2W configuration"
elif [ "$PI_MODEL" = "zerow" ]; then
    sudo cp /home/pi/firmware/bin/root/boot/config_zerow.txt /boot/config.txt
    echo "Installed Zero W configuration"
else
    echo "Unknown Pi model. Please ensure you're using a Pi Zero W or Pi Zero 2W"
    exit 1
fi

# Add predefined wifi networks Hackpack can join

echo ""
echo "Installing wifi networks..."
echo ""

# sudo cp /home/pi/firmware/bin/root/boot/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf
echo "" | sudo tee --append /etc/wpa_supplicant/wpa_supplicant.conf
echo "network={" | sudo tee --append /etc/wpa_supplicant/wpa_supplicant.conf
echo "    ssid=\"SIGNAL18\"" | sudo tee --append /etc/wpa_supplicant/wpa_supplicant.conf
echo "    psk=\"Join us at signal\"" | sudo tee --append /etc/wpa_supplicant/wpa_supplicant.conf
echo "    id_str=\"signal_guest\"" | sudo tee --append /etc/wpa_supplicant/wpa_supplicant.conf
echo "}" | sudo tee --append /etc/wpa_supplicant/wpa_supplicant.conf
echo "" | sudo tee --append /etc/wpa_supplicant/wpa_supplicant.conf
echo "network={" | sudo tee --append /etc/wpa_supplicant/wpa_supplicant.conf
echo "    ssid=\"TwilioGuest\"" | sudo tee --append /etc/wpa_supplicant/wpa_supplicant.conf
echo "    psk=\"join us at twilio\"" | sudo tee --append /etc/wpa_supplicant/wpa_supplicant.conf
echo "    id_str=\"twilio_guest\"" | sudo tee --append /etc/wpa_supplicant/wpa_supplicant.conf
echo "}" | sudo tee --append /etc/wpa_supplicant/wpa_supplicant.conf
echo "" | sudo tee --append /etc/wpa_supplicant/wpa_supplicant.conf

# Configure boot-time background image

echo ""
echo "Installing Hackpack boot background image"
echo ""

sudo cp /home/pi/firmware/bin/root/opt/splash.png /opt/splash.png

# Install drivers

echo ""
echo "Installing drivers..."
echo ""

sudo cp -r /home/pi/firmware/drivers /home/pi

# Set up boot sequencing

echo ""
echo "Setting up boot sequencing..."
echo ""

sudo cp /home/pi/firmware/bin/root/home/pi/.config/lxsession/LXDE-pi/autostart /home/pi/.config/lxsession/LXDE-pi/autostart
sudo chmod 775 /home/pi/firmware/bin/boot.sh


echo ""
echo "Setting up Doom..."
echo ""

# Soon

echo ""
echo "Finished installing driver support"
echo ""
