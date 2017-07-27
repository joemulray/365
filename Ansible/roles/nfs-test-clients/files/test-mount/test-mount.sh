#!/bin/bash

#check if already mounted
if ! grep -qs 'mnt/nfs/export/ro' /proc/mounts; then
	#mount points
	sudo mount 10.246.251.75:/export/ro /mnt/export/nfs/ro
	sudo mount 10.246.251.75:/export/map-to-nobody /mnt/nfs/export/map-to-nobody
	sudo mount 10.246.251.75:/export/map-to-u1 /mnt/nfs/export/map-to-u1
	sudo mount 10.246.251.75:/export/hard /mnt/nfs/export/hard
	sudo mount 10.246.251.75:/export/soft /mnt/nfs/export/soft
fi

