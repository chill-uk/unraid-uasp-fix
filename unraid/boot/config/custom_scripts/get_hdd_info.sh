#!/bin/bash

# Extract and format the model number and serial number using smartctl
model=$(smartctl -i "$devnode" | awk -F ': ' '/Device Model/ {print $2}')
serial=$(smartctl -i "$devnode" | awk -F ': ' '/Serial Number/ {print $2}')

# If the model or serial number are emtpty, try with hdparm
if [ -z "$model" ] || [ -z "$serial" ]; then
    model=$(hdparm -I "$devnode" | awk -F ': ' '/Model Number/ {print $2}')
    serial=$(hdparm -I "$devnode" | awk -F ': ' '/Serial Number/ {print $2}')
fi

# If the model or serial number are still empty, write an error message to the log
if [ -z "$model" ] || [ -z "$serial" ]; then
    echo "Error: Unable to retrieve model and serial number for $devnode" >> /var/log/syslog
fi

# If the model and serial were found, write them to the log and continue
if [ -n "$model" ] && [ -n "$serial" ]; then

    # Trim leading and trailing whitespace from model and serial
    model=$(echo "$model" | sed 's/^[ \t]*//;s/[ \t]*$//')
    serial=$(echo "$serial" | sed 's/^[ \t]*//;s/[ \t]*$//')

    # Replace spaces in the model number with underscores
    model=$(echo "$model" | sed 's/ /_/g')

    # Combine the formatted model number and serial number
    combined_info="ID_SERIAL=${model}_${serial}"

    echo "DevNode: $devnode, Model: $model, Serial: $serial" >> /var/log/syslog
    echo "DevNode: $devnode, Combined_info: $combined_info" >> /var/log/syslog
    # Output the combined information
    echo "$combined_info"
fi