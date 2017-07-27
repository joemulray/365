#!/bin/bash

# Joseph Mulray
# NFS Hosts Script file

#Create the Share Directory on the Host Server
Directory="/var/nfs"

#check if directory exists already
if [ ! -d $Directory  ]; then
    sudo mkdir /var/nfs
    sudo chown nobody:nogroup /var/nfs
fi

#Create the NFS table that holds the exports of your shares
sudo exportfs -a

#Start the NFS service
sudo service nfs-kernel-server start


#check if already mounted
if ! grep -qs '/mnt/nfs/home' /proc/mounts; then
     #mount points
     sudo mount 10.246.251.75:/home /mnt/nfs/home
     sudo mount 10.246.251.75:/var/nfs /mnt/nfs/var/nfs
fi

