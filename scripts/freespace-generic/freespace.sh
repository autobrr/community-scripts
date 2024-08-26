#!/bin/bash
set -e

reqSpace=100000000 # 100GB
SPACE=`df "$HOME/torrents" | awk 'END{print $4}'`
if [[ $SPACE -le reqSpace ]]
then
  #echo "not enough space"
  #echo "free $SPACE"
  exit 1
fi
#echo "got space"
#echo "free $SPACE"
exit 0