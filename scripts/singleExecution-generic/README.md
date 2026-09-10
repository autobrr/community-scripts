# Description

Using random delays and a temp file, this script prevents asynchronous workers from executing the same command.

This can be useful if for example you want to use a qui automation to initiate a **library scan** for services such as *Audiobookshelf\Plex\Navidrome\etc*. Such a scan is a **bulk** action that only needs a **single** execution, rather than **every** matched torrent of the automation initiating its own scan.

# Setup

1) Rename the `singleExection.sh` script to something more relevant to what you will be doing, such as `scanAudiobookshelf.sh`
2) Edit the `commandsToRun()` function so that it lists the command(s) you want to be run by only a single worker of a qui automation
3) Mount the script into your qui container and add the script as an **External Program**, so it can be used by your automations
