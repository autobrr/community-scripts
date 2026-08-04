#!/usr/bin/env python3
# coding: iso-8859-15

import argparse
import os
import requests
import sys
import yaml

from datetime import datetime

def make_full_path(filename):
	if not os.path.isabs(filename):
		if filename.startswith("~"):
			filename = os.path.expanduser(filename)
		else:
			script_directory = os.path.dirname(os.path.realpath(__file__))
			filename = os.path.join(script_directory, filename)
	return filename

# CLI arguments
parser = argparse.ArgumentParser(description="Check Autobrr IRC networks")
parser.add_argument("--all", action="store_true", help="Show all IRC networks")
args = parser.parse_args()

# Load configuration
config_filename = make_full_path('autobrr_infos.yaml')
with open(config_filename) as file:
	config = yaml.safe_load(file)

autobrr_url = config['url']
autobrr_username = config['username']
autobrr_password = config['password']
autobrr_api_token = config.get('api_token', None)

HEADERS = {"X-API-Token": autobrr_api_token, "Accept": "application/json"} if autobrr_api_token else {}

# Fetch IRC networks
try:
	r = requests.get(f"{autobrr_url}/irc",
					 auth=(autobrr_username, autobrr_password) if autobrr_username else None,
					 headers=HEADERS, timeout=15)
	r.raise_for_status()
	networks = r.json()
except Exception as e:
	print(f"? Unable to retrieve IRC networks: {e}")
	sys.exit(1)

problem_found = False

header = f"{'ID':>3} {'Name':40} {'Healthy':8}"

printed_header = False

for net in networks:
	net_id = net.get("id")
	name = net.get("name", f"Net {net_id}")
	healthy = net.get("healthy", False)

	if args.all:
		if not printed_header:
			print(header)
			printed_header = True
		print(f"{net_id:>3} {name[:40]:40} {str(healthy):8}")
	else:
		if not healthy:
			if not printed_header:
				print(header)
				printed_header = True
			print(f"{net_id:>3} {name[:40]:40} {str(healthy):8}")
			problem_found = True

if not args.all and not problem_found:
	print("All IRC networks are healthy.")
