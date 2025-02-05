# freebandwidth-hbd

This is a freebandwidth script that only works for HBD Shared App Slots.

```shell
touch ~/freebandwidth.sh && chmod +x ~/freebandwidth.sh
```

Then open the file and paste the contents.

## Description

If the script sees that there is enough network bandwidth available, it will return exit code 0 and autobrr will push the torrent to the download client.

If available bandwidth falls below your limit, the script will return exit code 1 and autobrr will skip it.

This script uses a command line argument so that you can pass the `100G` or `1T` variable from autobrr.
It adds a 10gb buffer to this value and then calculates if you have enough bandwidth.

Returns 0 if has bandwidth available, else returns 1.
