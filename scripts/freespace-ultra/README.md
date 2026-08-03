# freespace-ultra

This is a freespace script for Ultra.cc slots.

```shell
touch ~/freespace-ultra.sh && chmod +x ~/freespace-ultra.sh
```

Then open the file and paste the contents.

## Description

If the script sees that there is enough space available, it will return exit code 0 and autobrr will push the torrent to the download client.

If free space falls below your limit, the script will return exit code 1 and autobrr will skip it.

Set **Exec Args** to `{{.Size}}` and **Expected exit status** to `0`.

## Why not just df

On a slot your home directory sits on an array shared with every other user, and your plan is a filesystem user quota. `df` reports the array, not your quota, and qBittorrent's own "free space on disk" comes from the same place, so it is wrong in the same way.

A slot with 250 GiB of quota left can sit on an array reporting 10 TiB free. A `df` check never fires, and the grabs keep coming until writes fail.

So the script reads your quota, and uses the smaller of your quota headroom and the array, because either one can be what stops the write.

Everything here is in GiB, matching your torrent client. The Ultra panel shows GB, so the same space reads as a larger number there. 9313 GiB of quota is 10000 GB on the panel.

## Releases with no announced size

Not every tracker puts a size on the announce line. What happens then depends on whether your filter has a size constraint.

**Set a `Min Size` or `Max Size` on the filter.** autobrr then fetches the real size out of band, from the `.torrent` file or from the tracker API on RED, OPS, GGN and BTN. That happens in `CheckFilter` before external filters run, so `{{.Size}}` is already correct by the time this script executes and the check is exact. This is the recommended setup.

**With no size constraint at all**, `checkSizeFilter` is never reached, nothing is fetched, and `{{.Size}}` arrives as `0`. Reading `0` as "needs nothing" would let any release through, so the script falls back to `ASSUME_GIB`.

Set `ASSUME_GIB` to the largest release you would accept on that filter. It is only used in that fallback case.

## Configuration

Edit the values at the top of the script:

| Variable | Meaning |
| --- | --- |
| `BUFFER_GIB` | Headroom to keep free on top of the release. Default 50. |
| `ASSUME_GIB` | Fallback size, used only when the filter has no size constraint and the announce carries no size. Default 50. |
| `CHECK_PATH` | Any path on the filesystem you download to. Defaults to `$HOME`. |

`BUFFER_GIB` and `ASSUME_GIB` can also be passed as arguments, so one copy can serve several filters:

```
freespace-ultra.sh [RELEASE_BYTES] [BUFFER_GIB] [ASSUME_GIB]
```

To keep 100 GiB free on a filter, set **Exec Args** to `{{.Size}} 100`.

## Output

Every run prints both numbers, so a skipped grab explains itself:

```
freespace: OK - quota 250 GiB free, array 10509 GiB free, needs 55 GiB (release 5 GiB plus 50 GiB buffer)
freespace: BLOCK - quota 40 GiB free, array 10509 GiB free, needs 80 GiB (size unknown, assumed 30 GiB plus 50 GiB buffer)
```

## Notes

The script fails closed. If your quota cannot be read, it skips the release rather than falling back to `df`, because on a slot the array figure is not your headroom and trusting it is the failure this script exists to prevent.

It is POSIX `sh` and passes `shellcheck`.
