#!/bin/bash

# Joseph Mulray
#

#Verify the system user ntp is created correctly.

if [ -f /usr/sbin/ntpd ]; then
	echo $0 - OK
else
	echo $0 - Failure
fi
