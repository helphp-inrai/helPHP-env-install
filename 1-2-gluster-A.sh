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

gluster peer probe cluster-2

gluster volume create repl01 replica 2 transport tcp \
cluster-1:/media/replicated \
cluster-2:/media/replicated \
force 

gluster volume create dist01 replica 2 transport tcp \
cluster-1:/media/distreplic \
cluster-2:/media/distreplic \
force

gluster volume start repl01
gluster volume start dist01

gluster volume quota dist01 enable

gluster volume set dist01 quota-deem-statfs on

mount -t glusterfs localhost:/repl01 /mnt/replicated
mount -t glusterfs localhost:/dist01 /mnt/distreplic

echo "localhost:/repl01 /mnt/replicated glusterfs defaults,_netdev,noauto,x-systemd.automount 0 0 
localhost:/dist01 /mnt/distreplic glusterfs defaults,_netdev,noauto,x-systemd.automount 0 0" >> /etc/fstab

