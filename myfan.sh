#!/bin/bash

# Temperature thresholds
THRESHOLD_1=60
THRESHOLD_2=65
THRESHOLD_3=75
THRESHOLD_DISENGAGED=85

# File to read temperature from
TEMP_FILE="/sys/class/hwmon/hwmon4/temp1_input"

# Fan control file
FAN_CONTROL_FILE="/proc/acpi/ibm/fan"

# Default fan level to ensure safety at startup
DEFAULT_FAN_LEVEL=2

# Delay between checks (in seconds)
DELAY=10

# Initialize fan to default level at the start
if [ -f "$FAN_CONTROL_FILE" ]; then
  echo "Setting fan to default level $DEFAULT_FAN_LEVEL for safety at startup."
  echo "level $DEFAULT_FAN_LEVEL" > $FAN_CONTROL_FILE
else
  echo "Fan control file $FAN_CONTROL_FILE not found. Exiting."
  exit 1
fi

# Variable to keep track of the current fan level
CURRENT_FAN_LEVEL=$DEFAULT_FAN_LEVEL

while true; do
  # Check if temperature file exists
  if [ ! -f "$TEMP_FILE" ]; then
    echo "Temperature file $TEMP_FILE not found."
    exit 1
  fi

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

  # Check if the fan level has changed
  if [ "$FAN_LEVEL" != "$CURRENT_FAN_LEVEL" ]; then
    echo "Current temperature: $CURRENT_TEMP_C°C. Changing fan level to $FAN_LEVEL."
    echo "level $FAN_LEVEL" > $FAN_CONTROL_FILE
    CURRENT_FAN_LEVEL=$FAN_LEVEL
  fi

  # Wait before the next check
  sleep $DELAY
done
