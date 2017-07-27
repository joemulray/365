#!/bin/bash

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

useradd "$User"
#add user default shell
usermod -s /bin/sh "$User"

NewUid=$(getMaxUID)
NewGid=$(getMaxGID)

Shell=$(getent passwd "$User" | cut -d: -f7)

default="/bin/sh"

if [ "$Shell" == "$default" ]; then
    userdel -r "$User"
    echo $0 - OK
else
    echo $0 - Failed
fi

exit 0


