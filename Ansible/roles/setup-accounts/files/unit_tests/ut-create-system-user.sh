#!/bin/bash

#
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

#Create a system user and specify home directory and shell
useradd -r -s /bin/false -d /nowhere "$User"

NewUid=$(getMaxUID)
NewGid=$(getMaxGID)

HDir=$(getent passwd "$User" | cut -f 6 -d :)
Shell="/bin/false"


if [ $(($OldUid + 1)) != "$NewUid" ] && [ $((OldGid + 1)) != "$NewGid" ] && [ ! -d "$HDir" ] && [ -f "$Shell" ]
then
    echo $0 - OK
    userdel -r "$User"
else
    echo $0 - Failed
fi

exit 0

