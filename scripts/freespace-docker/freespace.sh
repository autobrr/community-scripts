#!/bin/sh
set -e

reqSpace=250000000 # 250GB
SPACE=$(df "/torrents" | awk 'END{print $4}')
if [ "$SPACE" -le $reqSpace ]
then
  echo "not enough space"
  echo "free $SPACE"
  exit 1
fi
echo "got space"
echo "free $SPACE"
exit 0