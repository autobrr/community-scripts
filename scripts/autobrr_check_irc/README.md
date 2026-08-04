Python script to check the health of IRC networks

You'll need a file named 'autobrr_infos.yaml' in the script's directory, with this info:

```
url: https://<autobrr_hostname_or_ip>/autobrr/api
username: <autobrr_username>
password: <autobrr_password>
api_token: <autobrr_api_token>
```

The script will either print a list of problems or a success message if everything is fine.

Parameter '--all' will print a list of all IRC networks with their status.

```
$ ./autobrr_check_irc.py --help
usage: autobrr_check_irc.py [-h] [--all]
Check Autobrr IRC networks
optional arguments:
  -h, --help  show this help message and exit
  --all       Show all IRC networks
```

```
$ ./autobrr_check_irc.py
All IRC networks are healthy.
```

```
$ ./autobrr_check_irc.py --all
 ID Name                                     Healthy
  3 Indexer03                                True
  4 Indexer04                                True
```



