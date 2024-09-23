# diskutil-hbd

This is a disk util script that only works for HBD Shared App Slots.

```shell
touch ~/diskutil.sh && chmod +x ~/diskutil.sh
```

Then open the file and paste the contents.

## Description

This script checks the total disk util of your alocated disk.

It checks multiple times. This can be configured by changing the constant `ITERATIONS`. And calculates the average. Each iteration takes one second.

It takes a command line argument which is the max percentage.

```shell
./diskutil.sh 80
```
If the util exceeds this value the script exits with a value of 1.
Else it exits 0.