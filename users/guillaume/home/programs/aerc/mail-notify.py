# Announces new unread mail with its sender and subject, for goimapnotify, which
# only says that some arrived:
#   mail-notify ACCOUNT HOST USER PASSWORD_FILE MAILBOX
# The mailbox's next UID is kept between runs, so each message is announced once,
# including mail that arrived while the laptop was off or asleep.
import email
import email.policy
import fcntl
import imaplib
import json
import os
import re
import subprocess
import sys

# More new messages than this at once get a single notification that counts them
MAX_SHOWN = 5

account, host, user, password_file, mailbox = sys.argv[1:]
quoted = '"' + mailbox.replace("\\", "\\\\").replace('"', '\\"') + '"'

state_dir = os.path.join(
    os.environ.get("XDG_STATE_HOME") or os.path.expanduser("~/.local/state"),
    "mail-notify",
)
os.makedirs(state_dir, exist_ok=True)
state_path = os.path.join(state_dir, f"{account}-{mailbox.replace('/', '-')}.json")


def notify(body):
    subprocess.run(
        ["notify-send", "--app-name=mail", f"New mail in {account}/{mailbox}", body],
        check=True,
    )


def describe(header):
    message = email.message_from_bytes(header, policy=email.policy.default)
    sender = message["from"]
    addresses = getattr(sender, "addresses", ())
    if addresses:
        sender = addresses[0]
    return f"From: {sender or '?'}\nSubject: {message['subject'] or '(no subject)'}"


with open(state_path, "a+") as state_file:
    # One run at a time per mailbox
    fcntl.flock(state_file, fcntl.LOCK_EX)
    state_file.seek(0)
    try:
        last = json.load(state_file)
    except ValueError:
        last = {}

    with open(password_file) as f:
        password = f.read().rstrip("\n")
    imap = imaplib.IMAP4_SSL(host, timeout=60)
    imap.login(user, password)
    _, [status] = imap.status(quoted, "(UIDVALIDITY UIDNEXT)")
    now = {
        key.lower(): int(re.search(rf"{key} (\d+)", status.decode())[1])
        for key in ("UIDVALIDITY", "UIDNEXT")
    }

    # The first run, and one after the server renumbered the mailbox, only take note
    if last.get("uidvalidity") == now["uidvalidity"] and now["uidnext"] > last["uidnext"]:
        imap.select(quoted, readonly=True)
        _, [found] = imap.uid("SEARCH", "UNSEEN", f"UID {last['uidnext']}:*")
        # n:* always matches the newest message, and anything newer than the
        # status above is left for the next run
        uids = [u.decode() for u in found.split() if last["uidnext"] <= int(u) < now["uidnext"]]
        if len(uids) > MAX_SHOWN:
            notify(f"{len(uids)} new messages")
        elif uids:
            # PEEK leaves the messages unread
            _, data = imap.uid(
                "FETCH", ",".join(uids), "(BODY.PEEK[HEADER.FIELDS (FROM SUBJECT)])"
            )
            for part in data:
                if isinstance(part, tuple):
                    notify(describe(part[1]))
    imap.logout()

    state_file.seek(0)
    state_file.truncate()
    json.dump(now, state_file)
