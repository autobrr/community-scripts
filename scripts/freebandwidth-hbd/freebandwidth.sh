#!/bin/bash
set -e

threshold=$(numfmt --from=iec ${1:-0}) # Defaults 0 if missing the argument
required_data=$((threshold + 10000000000)) # Add 10gb to keep small buffer
required_data_fmt=$(numfmt --to=iec --format='%.3f' $required_data)
echo "Needs this much of bandwidth: $required_data_fmt"

# Get the available bandwidth via `sudo box bw`, strip ascii modifiers via regex
box_bw=$(TERM=xterm sudo box bw | sed 's/\x1b\[[^m]*m//g; s/\x1b(B//g; s/\x1b\[0m//g')
total_data_fmt=$(grep 'Total' <<< $box_bw | awk '{print $3}')
used_data_fmt=$(grep 'Used' <<< $box_bw | awk '{print $3}')
available_data_fmt=$(grep 'Remaining' <<< $box_bw | awk '{print $3}')
available_data=$(numfmt --from=iec $available_data_fmt)

echo "---These values are rounded down---"
echo "Total Bandwidth: $total_data_fmt"
echo "Used Bandwidth: $used_data_fmt"
echo "Available Bandwidth: $available_data_fmt"

# Check if the available bandwidth is greater than or equal to the required bandwidth
if [ "$available_data" -ge "$required_data" ]; then
  echo "Has enough bandwidth available."
else
  echo "Insufficient bandwidth: $available_data_fmt available, needed: $required_data_fmt."
  exit 1
fi

exit 0
