#!/bin/bash
owner=$(who am i | awk '{print $1}')
if [ "$(whoami)" != 'root' ];
    then
        echo $"You have no permission to run $0 as non-root user. Use sudo"
        exit 1;
fi
mount -t glusterfs localhost:/repl01 /mnt/replicated
mount -t glusterfs localhost:/dist01 /mnt/distreplic

echo "localhost:/repl01 /mnt/replicated glusterfs defaults,_netdev,noauto,x-systemd.automount 0 0 
localhost:/dist01 /mnt/distreplic glusterfs defaults,_netdev,noauto,x-systemd.automount 0 0" >> /etc/fstab
