# freespace-hbd

This is a freespace script that only works for HBD Shared App Slots.

```shell
touch ~/freespace.sh && chmod +x ~/freespace.sh
```

Then open the file and paste the contents.

## Description

If the script sees that there is enough space available, it will return exit code 0 and autobrr will push the torrent to the download client.

If free space falls below your limit, the script will return exit code 1 and autobrr will skip it.

This script uses a command line argument so that you can pass the `{{.Size}}` variable from autobrr.
It adds a 10gb buffer to this value and then calculates if you have enough space.

Returns 0 if enough space, else returns 1.