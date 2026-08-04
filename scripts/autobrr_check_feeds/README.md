Python script to check the health of RSS feeds

NB: I don't have any Usenet indexers so I don't know if it handles Newsnab feeds correctly

You'll need a file named 'autobrr_infos.yaml' in the script's directory, with this info:

```
url: https://<autobrr_hostname_or_ip>/autobrr/api
username: <autobrr_username>
password: <autobrr_password>
api_token: <autobrr_api_token>
```

The script will either print a list of problems or a success message if everything is fine.

Parameter '--all' will print a list of all feeds with their status.

```
$ ./autobrr_check_feeds.py --help
usage: autobrr_check_feeds.py [-h] [--all]
Check Autobrr feeds
optional arguments:
  -h, --help  show this help message and exit
  --all       Show all feeds
```

```
$ ./autobrr_check_feeds.py
All feeds returned results on last run.
```

```
$ ./autobrr_check_feeds.py --all
 ID Name                                      Items Last run            Status
  1 Indexer01 (RSS)                              50 2025-09-03 14:58:44 OK
  2 Indexer02 (Prowlarr)                         25 2025-09-03 15:00:06 OK
```


