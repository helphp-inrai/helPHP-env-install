#!/bin/bash
## creating docker user

owner=$(who am i | awk '{print $1}')
if [ "$(whoami)" != 'root' ];
    then
        echo $"You have no permission to run $0 as non-root user. Use sudo"
        exit 1;
fi
##fix for trixie
export PATH=/usr/sbin:$PATH
echo "Creating docker dedicated user"
read -p "Enter the Docker username: " username
read -p "Enter its password : " password

## creating docker user and preparing some folders
useradd -ms /bin/bash -g users ${username} && chown -R ${username}:users /home/${username}
echo "$username:$password" | chpasswd

echo "$username:$password" | chpasswd
## add docker user in group
usermod -a -G docker ${username}
usermod -a -G www-data ${username}

## add docker user in group gluster to manage quota
usermod -a -G gluster ${username}
chmod u+s /usr/sbin/gluster
ln -s /usr/sbin/gluster /usr/bin/gluster

echo "docker user $username ready!"
