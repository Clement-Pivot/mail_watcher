#!/usr/bin/python3
from io import open
from sys import argv
import re

if len(argv) != 2:
	exit('Must specify mails file.')
lines = []
in_mail = False
recording = False
rep = ""
ip_regexp = re.compile(r'([0-9]{1,3}\.){3}[0-9]{1,3}')

with open(argv[1], "r") as mails:
	try:
		for line in mails:
			if in_mail:
				if "Date:" in line:
					rep += line + "</br>"
				elif "Hi," in line:
					recording = True
					rep += "<p>"
				elif "Regards," in line:
					in_mail = False
					recording = False
					rep += "</p>"
				elif recording:
					rep += line + "</br>"
			else:
				if ip_regexp.search(line) and "Subject:" in line :
					in_mail = True
		print(rep)
	except Exception as e:
		print(e)

