#!/bin/bash

# Temperature thresholds
THRESHOLD_1=60
THRESHOLD_2=65
THRESHOLD_3=75
THRESHOLD_DISENGAGED=85

# File to read temperature from
TEMP_FILE="/sys/class/hwmon/hwmon4/temp1_input"

# Read current temperature
CURRENT_TEMP=$(cat $TEMP_FILE)
CURRENT_TEMP_C=$((CURRENT_TEMP / 1000))

# Determine fan level
if [ "$CURRENT_TEMP_C" -ge "$THRESHOLD_DISENGAGED" ]; then
  FAN_LEVEL="disengaged"
elif [ "$CURRENT_TEMP_C" -ge "$THRESHOLD_3" ]; then
  FAN_LEVEL=7
elif [ "$CURRENT_TEMP_C" -ge "$THRESHOLD_2" ]; then
  FAN_LEVEL=4
elif [ "$CURRENT_TEMP_C" -ge "$THRESHOLD_1" ]; then
  FAN_LEVEL=2
else
  FAN_LEVEL=1
fi

# Set fan speed
echo level $FAN_LEVEL > /proc/acpi/ibm/fan
