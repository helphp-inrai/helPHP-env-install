#!/bin/bash
### installing packets and sofware for hosts...
owner=$(who am i | awk '{print $1}')
if [ "$(whoami)" != 'root' ];
    then
        echo $"You have no permission to run $0 as non-root user. Use sudo"
        exit 1;
fi

##fix for trixie
export PATH=/usr/sbin:$PATH

apt update --fix-missing && apt -y upgrade

##paquets
echo "install basic utils"
apt install -y --no-install-recommends \
apt-utils \
lsb-release \
ca-certificates \
apt-transport-https \
gnupg2 \
wget \
fail2ban \
apparmor \
iftop \
wget \
git \
rsync \
curl \
pv \
openssl \
p7zip-full \
fail2ban apparmor iftop \
wget git rsync curl pv \
openssl \
p7zip-full \
gnupg \
lsb-release

## docker + glusterfs
echo "installing docker and glusterFS"

apt remove docker docker-engine docker.io containerd runc -y
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

apt update
apt install -y glusterfs-server glusterfs-client && systemctl start docker
apt upgrade -y

apt clean && apt autoremove
##swap optimisation:
echo "swap and memory cache optimisation"
echo vm.swappiness=10 | tee /etc/sysctl.d/99-swappiness.conf
echo vm.vfs_cache_pressure=50 | tee -a /etc/sysctl.d/99-swappiness.conf
sysctl -p /etc/sysctl.d/99-swappiness.conf
swapoff -a
swapon -a

##fail2ban configuration
echo "fail2ban configuration"
echo "[sshd]
enabled = true
port = 22
backend=systemd
#filter = sshd
#logpath = /var/log/auth.log
maxretry = 3" > /etc/fail2ban/jail.local

sed -i "s/bantime  = 10m/bantime  = 720m/" /etc/fail2ban/jail.conf

systemctl restart fail2ban

echo "Finished, please continue with step 0-1 or 1-0..."
