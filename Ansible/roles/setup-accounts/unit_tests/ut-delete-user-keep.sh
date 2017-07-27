#!/bin/bash

#
# Create a new user and delete without removing homedirectory
#

function getMaxUID {
    getent passwd | sort -nr  -k +3 -t : | grep -v nobody | head -n 1 | cut -f 3 -d :
}

function getMaxGID {
    getent group | sort -nr  -k +3 -t : | grep -v nogroup | head -n 1 | cut -f 3 -d :
}

OldUid=$(getMaxUID)
OldGid=$(getMaxGID)
User=gmcfoo-$((OldUid + 1))

useradd -m "$User"

NewUid=$(getMaxUID)
NewGid=$(getMaxGID)

HDir=$(getent passwd "$User" | cut -f 6 -d :)

#Delete the user without removing home directory
userdel "$User"

if [ $(($OldUid + 1)) == "$NewUid" ] && [ $((OldGid + 1)) == "$NewGid" ] && [ -d "$HDir" ]
then
    echo $0 - OK
else
    echo $0 - Failed
fi

exit 0

