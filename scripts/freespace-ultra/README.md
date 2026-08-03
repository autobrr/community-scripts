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

Not every tracker puts a size on the announce line. autobrr only works the real size out *after* external filters have run:

```go
func (f *Filter) checkSizeFilter(r *Release) bool {
	if r.Size == 0 {
		r.AdditionalSizeCheckRequired = true
		return true
	}
```

So `{{.Size}}` arrives here as `0`, and a `max_size` on the filter does not change that. Reading `0` as "needs nothing" would let any release through, so the script assumes `ASSUME_GIB`.

Set `ASSUME_GIB` to your filter's `max_size`. That is the largest release the filter can accept, so the guess is never too big or too small.

## Configuration

Edit the values at the top of the script:

| Variable | Meaning |
| --- | --- |
| `BUFFER_GIB` | Headroom to keep free on top of the release. Default 50. |
| `ASSUME_GIB` | Size assumed when the announce carries no size. Set to your filter's `max_size`. Default 50. |
| `CHECK_PATH` | Any path on the filesystem you download to. Defaults to `$HOME`. |

`BUFFER_GIB` and `ASSUME_GIB` can also be passed as arguments, so one copy can serve several filters:

```
freespace-ultra.sh [RELEASE_BYTES] [BUFFER_GIB] [ASSUME_GIB]
```

For a filter with `max_size` of 30GB that should keep 100 GiB free, set **Exec Args** to `{{.Size}} 100 30`.

## Output

Every run prints both numbers, so a skipped grab explains itself:

```
freespace: OK - quota 250 GiB free, array 10509 GiB free, needs 55 GiB (release 5 GiB plus 50 GiB buffer)
freespace: BLOCK - quota 40 GiB free, array 10509 GiB free, needs 80 GiB (size unknown, assumed 30 GiB plus 50 GiB buffer)
```

## Notes

The script fails closed. If your quota cannot be read, it skips the release rather than falling back to `df`, because on a slot the array figure is not your headroom and trusting it is the failure this script exists to prevent.

It is POSIX `sh` and passes `shellcheck`.
