#!/bin/bash

# Using random delays and a temp file, this script prevent asynchronous workers from executing the same command.

function commandsToRun() {
    # The commands that will be run by the first worker of the race 

    # Audiobookshelf Library Scan
    curl -X POST -H 'Authorization: Bearer __APIKEY__' 'http://192.168.1.10:13378/audiobookshelf/api/libraries/__LIBRARYID__/scan?force=0'

    # Navidrome Library Scan: https://www.subsonic.org/pages/api.jsp
    curl 'http://192.168.1.10:4533/rest/startScan?c=NavidromeUI&fullScan=false&f=json&v=1.8.0&u=__USERNAME__&t=__TOKEN__&s=__SALT__'

}

# The minimum and maximum random delay (seconds) for each worker. The larger the difference, the less likely workers are to overlap, so use a larger maximum when expecting many workers
MINWAIT=1
MAXWAIT=45

# =========================== CODE ===========================

# The temp file that will be created by the first worker of the race
scriptName=$(basename -s '.sh' "$0")
tempFile="/tmp/${scriptName}__tempFile"

# Stagger this worker by introducing a random delay
sleep $((MINWAIT+RANDOM % (MAXWAIT-MINWAIT)))

if [[ -e $tempFile ]]
then

    # The temp file ALREADY exists, so do nothing with this worker
    exit

else

    # The temp file does NOT exists, so call commandstoRun() with this worker

    # Create the temp file, which will stop other workers from passing the 'if' check above
    touch $tempFile

    workersWait=$((MAXWAIT+5))

    # Execute the commands definied in the function above
    printf "\n$scriptName: The first worker is ready and the temp file has been made, executing commands...\n\n"
    commandsToRun

    # Wait until all other workers have finished their random delay and then remove the temp file from the system
    printf "\n\n$scriptName: The commands have been executed, waiting ${workersWait}s to make sure all workers exit before deleting the temp file..."
    sleep $workersWait
    rm $tempFile
    exit

fi
