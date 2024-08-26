# freespace-generic

This is a generic freespace script that should work in most environments.

```shell
touch ~/freespace.sh && chmod +x ~/freespace.sh
```

Then open the file and paste the contents.

## Description

If the script sees that there is enough space available, it will return exit code 0 and autobrr will push the torrent to the download client.

If free space falls below your limit, the script will return exit code 1 and autobrr will skip it.

Adjust `reqSpace` to fit your needs.