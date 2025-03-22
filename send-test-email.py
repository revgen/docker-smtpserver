#!/usr/bin/env python3
##############################################################################
# Test script to send simple email via SMTP server on localhost:25
# The script is using sys.env variable SMTP_USERNAME as a From address
#
##############################################################################
from datetime import datetime
from pathlib import Path
import sys
import smtplib

SRIPT_PATH = Path(__file__)

PARAMS_FILE = SRIPT_PATH.parent / ".env"
# Read parameters fro the .env file in the project directory
if PARAMS_FILE.exists():
    print(f"Read parameters from the file: {PARAMS_FILE}")
    params = {l[0]: l[1] for l in ((p + "=").split("=") for p in PARAMS_FILE.read_text().splitlines())}
else:
    print(f"File '{PARAMS_FILE}' not found. Skip reading it.")

from_addr = params["SMTP_USERNAME"]
to_addr = (sys.argv[1] if len(sys.argv) > 1 else params.get("RECIPIENT")) or from_addr
subject = f"Sample test notification message at {datetime.now().isoformat()}"
body = f"Hi, this is a test message from {Path(__file__).stem} script. \n- {from_addr}"

email_text = f"From: Sender <{from_addr}>\nTo: {to_addr}\nSubject: {subject}\n\n{body}\n"

print(f"Sending email from '{from_addr}' to '{to_addr}'...")
print(f"-- RAW MESSAGE {'-'*40}\n{email_text}\n{'-'*55}")

try:
    # server = smtplib.SMTP_SSL("smtp.gmail.com", 465)
    server = smtplib.SMTP("localhost", 25)
    server.ehlo()
    server.debuglevel = 1
    res = server.sendmail(from_addr, [to_addr], email_text)
    server.close()

    print(f"Email sent: {res}")
except Exception as ex:  
    print(f"Something went wrong: {ex}")
    sys.exit(1)
