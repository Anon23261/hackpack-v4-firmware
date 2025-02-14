#!/bin/bash

# Configuration
QEMU_SYSTEM="qemu-system-arm"
MEMORY="512M"
SD_CARD="sd_card.qcow2"

# Common QEMU options
common_opts="-nographic -monitor none"

# Function to test Pi Zero W configuration
test_zero_w() {
    echo "Testing Pi Zero W configuration..."
    $QEMU_SYSTEM \
        -M raspi0 \
        -cpu arm1176 \
        -m $MEMORY \
        -sd $SD_CARD \
        -dtb ../firmware/boot/bcm2708-rpi-zero-w.dtb \
        -append "console=ttyAMA0,115200 root=/dev/mmcblk0p2 rootfstype=ext4 elevator=deadline rootwait" \
        -device usb-net,netdev=net0 \
        -netdev user,id=net0 \
        -device usb-kbd \
        -device usb-mouse \
        $common_opts
}

# Function to test Pi Zero 2W configuration
test_zero_2w() {
    echo "Testing Pi Zero 2W configuration..."
    $QEMU_SYSTEM \
        -M raspi0-2 \
        -cpu cortex-a53 \
        -m $MEMORY \
        -sd $SD_CARD \
        -dtb ../firmware/boot/bcm2710-rpi-zero-2-w.dtb \
        -append "console=ttyAMA0,115200 root=/dev/mmcblk0p2 rootfstype=ext4 elevator=deadline rootwait" \
        -device usb-net,netdev=net0 \
        -netdev user,id=net0 \
        -device usb-kbd \
        -device usb-mouse \
        $common_opts
}

# Create directory for DTB files
mkdir -p ../firmware/boot

# Download DTB files if they don't exist
if [ ! -f ../firmware/boot/bcm2708-rpi-zero-w.dtb ]; then
    echo "Downloading Pi Zero W DTB..."
    wget -O ../firmware/boot/bcm2708-rpi-zero-w.dtb \
        https://raw.githubusercontent.com/raspberrypi/firmware/master/boot/bcm2708-rpi-zero-w.dtb
fi

if [ ! -f ../firmware/boot/bcm2710-rpi-zero-2-w.dtb ]; then
    echo "Downloading Pi Zero 2W DTB..."
    wget -O ../firmware/boot/bcm2710-rpi-zero-2-w.dtb \
        https://raw.githubusercontent.com/raspberrypi/firmware/master/boot/bcm2710-rpi-zero-2-w.dtb
fi

# Main test sequence
echo "Starting firmware tests..."

echo "1. Testing model detection..."
bash ../bin/detect_model.sh

echo "2. Testing Pi Zero W configuration..."
test_zero_w

echo "3. Testing Pi Zero 2W configuration..."
test_zero_2w

echo "Tests completed."
