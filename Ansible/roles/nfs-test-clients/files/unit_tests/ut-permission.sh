#!/bin/bash

Directory='/mnt/nfs/export/map-to-u1/'

cd $Directory
touch root

sudo -u \#49 -g \#58 touch u1

OUTPUT="$(ls -l root)"
OUTPUT1="$(ls -l u1)"

if [ "$OUTPUT" != *'root'* ] && [ "$OUTPUT1" != *'u1'* ];then
	echo $0 - OK
else
	echo $0 - Failed
fi
