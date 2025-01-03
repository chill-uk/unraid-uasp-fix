#!/bin/bash

# Function to strip partition number from device name
strip_partition() {
    echo "$1" | sed -E 's/([[:alpha:]/]+)([0-9]+)$/\1/'
}

# Log for debugging purposes
echo "Debug: Running get_hdd_info.sh for $1" >> /tmp/udev_debug.log

# Strip partition number if present
DEVICE=$(strip_partition "$1")
echo "Debug: Using device $DEVICE" >> /tmp/udev_debug.log

# Extract Serial Number
serial=$(hdparm -I "$DEVICE" | grep -i "Serial Number" | awk '{print $NF}')
echo "Debug: Serial number found: $serial" >> /tmp/udev_debug.log

# Check if serial and model were found
if [ -z "$serial" ]; then
    echo "Debug: Failed to extract serial for $DEVICE" >> /tmp/udev_debug.log
    exit 1
fi

# Output the values to be used by udev
echo "SERIAL=TOSHIBA_MG08ACA16TE_$serial"

echo "Debug: Script completed successfully for $DEVICE" >> /tmp/udev_debug.log