#!/usr/bin/python3

import os
import sys
import urllib.request
import json

# --- Environment variables ---
FORGEJO_TOKEN = os.getenv("FORGEJO_TOKEN")
FORGEJO_HOST = os.getenv("FORGEJO_HOST", "git.eden-emu.dev")
FORGEJO_REPO = os.getenv("FORGEJO_REPO")
FORGEJO_BRANCH = os.getenv("FORGEJO_BRANCH")

def get_forgejo_field(**kwargs):
    field = kwargs.get("field", "sha")
    pull_request_number = kwargs.get("pull_request_number", "")
    default_msg = kwargs.get("default_msg", "No data provided")

    headers = {}
    # "fake" req to see if the token works
    if FORGEJO_TOKEN:
        req = urllib.request.Request(
            f"https://{FORGEJO_HOST}/api/v1/user",
            headers={"Authorization": f"token {FORGEJO_TOKEN}"}
        )
        # and if it does we use it always, to save ourselves from the hell of ratelimiting
        try:
            with urllib.request.urlopen(req) as response:
                if response.getcode() == 200:
                    headers["Authorization"] = f"token {FORGEJO_TOKEN}"
        except urllib.error.HTTPError:
            pass

    if pull_request_number:
        url = f"https://{FORGEJO_HOST}/api/v1/repos/{FORGEJO_REPO}/pulls/{pull_request_number}"
    else:
        url = f"https://{FORGEJO_HOST}/api/v1/repos/{FORGEJO_REPO}/commits?sha={FORGEJO_BRANCH}&limit=1"

    try:
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode())
    except (urllib.error.HTTPError, urllib.error.URLError, json.JSONDecodeError) as e:
        print(e)
        print(f"Attempted URL {url}, host {FORGEJO_HOST}, repo {FORGEJO_REPO}")
        sys.exit(1)

    try:
        json.loads(json.dumps(data))
    except json.JSONDecodeError as e:
        print(e)
        sys.exit(1)

    if pull_request_number:
        if field == "title":
            result = data.get("title", "")
        elif field == "body":
            result = data.get("body", "")
        elif field == "sha":
            result = data.get("head", {}).get("sha", "")[:10]
        else:
            result = ""
    else:
        if not data or not isinstance(data, list) or not data[0]:
            result = ""
        elif field == "title":
            message = data[0].get("commit", {}).get("message", "")
            result = message.split("\n")[0] if message else ""
        elif field == "body":
            message = data[0].get("commit", {}).get("message", "")
            result = "\n".join(message.split("\n")[1:]) if message else ""
        elif field == "sha":
            result = data[0].get("sha", "")[:10]
        else:
            result = ""

    return result if result else default_msg

if __name__ == "__main__":
    if not (FORGEJO_HOST and FORGEJO_REPO):
        print("[ERROR] Missing host or repository, cannot get commit fields.")
        sys.exit(1)

    args = {}
    for arg in sys.argv[1:]:
        key, value = arg.split("=", 1)
        args[key] = value
    print(get_forgejo_field(**args))