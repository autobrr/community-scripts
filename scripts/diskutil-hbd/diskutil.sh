#!/bin/bash

# Set the number of iterations to calculate the average disk util
readonly ITERATIONS=4

# Check if a threshold was provided as a command-line argument
if [ -z "$1" ]; then
    echo "Error: No threshold provided."
    exit 1
fi

# Set the threshold value from the first command-line argument
THRESHOLD=$1

# Function to get disk utilization (trims percentage symbol)
get_disk_util() {
    iostat -xmyh 1 1 $(findmnt $HOME | awk '{ print $2 }' | tail -n1 | cut -d[ -f1) | awk 'NR == 17 {print $(NF-1)}' | tr -d '%'
}

# Initialize variables to store total utilization and individual values
total_util=0
util_values=()

# Loop to gather disk utilization multiple times
for (( i=1; i<=$ITERATIONS; i++ ))
do
    # Get the current disk utilization and add it to the array
    current_util=$(get_disk_util)
    util_values+=("$current_util")

    # Add the current utilization to the total
    total_util=$(echo "$total_util + $current_util" | bc -l)

    # Optional: Sleep for 1 second before the next iteration
    # sleep 1
done

# Calculate the average utilization
average_util=$(echo "$total_util / $ITERATIONS" | bc -l)

# Log the individual disk utilization readings and the calculated average
echo "Disk utilization readings (over $ITERATIONS iterations):"
for (( i=0; i<${#util_values[@]}; i++ ))
do
    echo "Utilization $(($i+1)): ${util_values[$i]}%"
done
echo "Average utilization: $average_util%"
echo "Threshold: $THRESHOLD%"

# Compare the average disk utilization with the threshold
if (( $(echo "$average_util > $THRESHOLD" | bc -l) )); then
    # Log message and return 1 if average disk utilization is higher than the threshold
    echo "Average utilization ($average_util%) exceeds the threshold ($THRESHOLD%). Exiting with status 1."
    exit 1
else
    # Log message and return 0 if average disk utilization is lower than or equal to the threshold
    echo "Average utilization ($average_util%) is below the threshold ($THRESHOLD%). Exiting with status 0."
    exit 0
fi