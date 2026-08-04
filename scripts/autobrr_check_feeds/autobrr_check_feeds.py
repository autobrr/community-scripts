#!/usr/bin/env python3
# coding: iso-8859-15

import argparse
import json
import os
import requests
import sys
import xml.etree.ElementTree as ET
import yaml

from datetime import datetime
from dateutil.tz import tzlocal

def make_full_path(filename):
    if not os.path.isabs(filename):
        if filename.startswith("~"):
            filename = os.path.expanduser(filename)
        else:
            script_directory = os.path.dirname(os.path.realpath(__file__))
            filename = os.path.join(script_directory, filename)
    return filename

def parse_iso(dt_str):
	try:
		return datetime.fromisoformat(dt_str.replace("Z", "+00:00")).astimezone()
	except Exception:
		return None

def count_last_run_data(last_run_data):
	"""Return the number of items in last_run_data (JSON or XML).
	Returns (count, error) where error is True if parsing fails.
	"""
	if not last_run_data:
		return 0, True

	# Try JSON
	try:
		data = json.loads(last_run_data)
		items = data.get("items", [])
		return len(items), False
	except json.JSONDecodeError:
		pass

	# Try XML
	try:
		root = ET.fromstring(last_run_data)
		return len(root.findall(".//item")), False
	except ET.ParseError:
		return 0, True

# CLI arguments
parser = argparse.ArgumentParser(description="Check Autobrr feeds")
parser.add_argument("--all", action="store_true", help="Show all feeds")
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

# Fetch feeds
try:
	r = requests.get(f"{autobrr_url}/feeds", auth=(autobrr_username, autobrr_password),
					 headers=HEADERS, timeout=15)
	r.raise_for_status()
	feeds = r.json()
except Exception as e:
	print(f"? Unable to retrieve feeds: {e}")
	sys.exit(1)

problem_found = False

header = f"{'ID':>3} {'Name':40} {'Items':>6} {'Last run':19} {'Status'}"

printed_header = False

for feed in feeds:

	if not feed.get("enabled", False):
		continue

	id = feed.get("id")
	name = feed.get("name", f"Feed {feed.get('id')}")
	last_run = parse_iso(feed.get("last_run"))
	last_run_data = feed.get("last_run_data", "")

	count, error = count_last_run_data(last_run_data)
	last_run_display = last_run.strftime('%Y-%m-%d %H:%M:%S') if last_run else '?'
	status = "OK" if not error else "Error"

	if args.all:
		if not printed_header:
			print(header)
			printed_header = True
		print(f"{id:>3} {name[:40]:40} {count:>6} {last_run_display} {status}")
	else:
		if count == 0 or error:
			if not printed_header:
				print(header)
				printed_header = True
			print(f"{id:>3} {name[:40]:40} {count:>6} {last_run_display} {status}")
			problem_found = True

if not args.all and not problem_found:
	print("All feeds returned results on last run.")

