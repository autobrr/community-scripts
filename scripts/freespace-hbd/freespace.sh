#!/bin/bash
set -e

readonly BILLION=1000000000

required_space=$(($1 + 10000000000)) #Add 10gb to keep small buffer
echo "Needs this much space: $((required_space / BILLION))GB"

# Get the available disk space via quota, remove non-numericals via regex
total_space=$(quota -s -u $(whoami) | grep "/dev/" | awk '{print $4}' | sed 's/[^0-9]*//g')
used_space=$(quota -s -u $(whoami) | grep "/dev/" | awk '{print $2}' | sed 's/[^0-9]*//g')
available_space=$(( (total_space - used_space) * BILLION)) 

echo "---These values are rounded down---"
echo "Total Space: $total_space GB"
echo "Used Space: $used_space GB"
echo "Available Space: $((available_space / BILLION))GB"

# Check if the available space is greater than or equal to the required space
if [ "$available_space" -ge "$required_space" ]; then
  echo "Disk has enough space."
else
  echo "Insufficient disk space: $available_space bytes available, needed: $required_space bytes."
  exit 1
fi
exit 0