#!/bin/bash
owner=$(who am i | awk '{print $1}')
if [ "$(whoami)" != 'root' ];
    then
        echo $"You have no permission to run $0 as non-root user. Use sudo"
        exit 1;
fi
username=$1
password=$2
##fix for trixie
export PATH=/usr/sbin:$PATH
##
##base folders 
mkdir /mnt/replicated
mkdir /mnt/mysql-db
mkdir /mnt/distreplic

apt install -y curl
apt remove docker docker-engine docker.io containerd runc -y
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

## creating docker user and preparing some folders
useradd -ms /bin/bash -g users ${username} && chown -R ${username}:users /home/${username}
echo "$username:$password" | chpasswd
chown -R ${username} :www-data /mnt/
## add docker user in group
usermod -a -G docker ${username}
usermod -a -G www-data ${username}
