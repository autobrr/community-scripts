#!/bin/sh
# freespace-ultra - autobrr External Filter script for Ultra.cc slots.
#
# Exit 0 if the release fits, 1 if it does not or the quota cannot be read.
# Usage: freespace-ultra.sh [RELEASE_BYTES] [BUFFER_GIB] [ASSUME_GIB]

set -u

buffer_gib=50        # keep this much free on top of the release
assume_gib=50        # assume this size when the announce carries none
check_path="$HOME"   # any path on the filesystem you download to

kib_per_gib=1048576
bytes_per_kib=1024

die() { echo "freespace: $1"; exit 1; }
is_number() { case "$1" in ''|*[!0-9]*) return 1 ;; esac; }

release_bytes="${1:-0}"
[ $# -ge 2 ] && buffer_gib="$2"
[ $# -ge 3 ] && assume_gib="$3"

is_number "$buffer_gib" || die "BUFFER_GIB must be a whole number, got '$buffer_gib'"
is_number "$assume_gib" || die "ASSUME_GIB must be a whole number, got '$assume_gib'"

# Your quota, in 1 KiB blocks. A slot has exactly one quota row:
#   Disk quotas for user user1 (uid 1000):
#        Filesystem  blocks   quota   limit   grace   files   quota   limit
#         /dev/sda1 9503171676  9765388288 9765388288           20081  0  0
# Not `quota -s`: it prints human units that change scale, so a 1.5T limit reads
# back as 15 once the letters are stripped. `blocks` gains a '*' when over soft.
used_kib=""
limit_kib=""
while read -r fs blocks soft hard _rest; do
    blocks=${blocks%\*}
    is_number "$fs" && continue          # a wrapped row leads with a number
    is_number "$blocks" || continue      # skips both header lines
    used_kib=$blocks
    limit_kib=$hard
    [ "$limit_kib" = 0 ] && limit_kib=$soft
    break
done <<EOF
$(quota -w 2>/dev/null)
EOF

# No quota is not a valid state on a slot, it is a fault. df alone would report
# the shared array, which is terabytes, so grabbing on that would fill the disk.
[ -n "$used_kib" ] || die "BLOCK - cannot read your quota, so nothing is safe to grab"
is_number "$limit_kib" || die "BLOCK - quota limit is not a number, got '$limit_kib'"
[ "$limit_kib" != 0 ] || die "BLOCK - no quota limit is set on this slot"

quota_free_kib=$(( limit_kib - used_kib ))
[ "$quota_free_kib" -lt 0 ] && quota_free_kib=0

# The shared array can fill while your quota still has room, so take the smaller:
#   Filesystem     1024-blocks       Used   Available Capacity Mounted on
#   /dev/sda1      27328354232 16305874084 11019729288      60% /home1
read -r _dev _blocks _used array_free_kib _rest <<EOF
$(df -Pk "$check_path" 2>/dev/null | tail -n 1)
EOF
is_number "$array_free_kib" || die "cannot read df for $check_path"

free_kib=$quota_free_kib
[ "$array_free_kib" -lt "$free_kib" ] && free_kib=$array_free_kib

# {{.Size}} is 0 only when the announce carries no size AND the filter sets no
# Min/Max Size. With one set, autobrr fetches the real size before external
# filters run. Reading 0 as "needs nothing" would let any release through.
if [ -z "$release_bytes" ] || [ "$release_bytes" = 0 ]; then
    need_kib=$(( assume_gib * kib_per_gib ))
    size_note="size unknown, assumed $assume_gib GiB"
elif is_number "$release_bytes"; then
    need_kib=$(( (release_bytes + bytes_per_kib - 1) / bytes_per_kib ))
    size_note="release $(( need_kib / kib_per_gib )) GiB"
else
    die "RELEASE_BYTES must be a whole number, got '$release_bytes'. Use {{.Size}}."
fi

need_kib=$(( need_kib + buffer_gib * kib_per_gib ))

report="quota $(( quota_free_kib / kib_per_gib )) GiB free, array $(( array_free_kib / kib_per_gib )) GiB free, needs $(( need_kib / kib_per_gib )) GiB ($size_note plus $buffer_gib GiB buffer)"

if [ "$free_kib" -le "$need_kib" ]; then
    echo "freespace: BLOCK - $report"
    exit 1
fi

echo "freespace: OK - $report"
exit 0
