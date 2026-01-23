#!/bin/bash
## let' go to gluster
owner=$(who am i | awk '{print $1}')
if [ "$(whoami)" != 'root' ];
    then
        echo $"You have no permission to run $0 as non-root user. Use sudo"
        exit 1;
fi
##fix for trixie
export PATH=/usr/sbin:$PATH
echo "export PATH=/usr/sbin:$PATH" >> ~/.bashrc
systemctl enable --now glusterd
mkdir /mnt/replicated /mnt/mysql-db /mnt/distreplic
mkdir /media/replicated /media/distreplic


