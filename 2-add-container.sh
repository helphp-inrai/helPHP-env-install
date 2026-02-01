#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

owner=$(who am i | awk '{print $1}')
if [ "$(whoami)" != 'root' ];
    then
        echo $"You have no permission to run $0 as non-root user. Use sudo"
        exit 1;
fi
servername=$1
dockeruser=$2

mkdir -p /mnt/replicated/${servername}/confs
mkdir -p /mnt/distreplic/logs/${servername}/apache2
mkdir -p /mnt/distreplic/custhome/${servername}/default
mkdir -p /mnt/distreplic/tmps/${servername}
cp -r "$SCRIPT_DIR/confs/helphp-instance/"* /mnt/replicated/${servername}/confs/

git clone https://github.com/INRAI-helPHP/helPHP-instance.git /mnt/distreplic/custhome/${servername}/default

chown -R ${dockeruser}:www-data /mnt/replicated/${servername}/* 
chown -R www-data:www-data  /mnt/distreplic/logs/${servername} /mnt/distreplic/custhome/${servername} /mnt/distreplic/tmps/${servername} /mnt/distreplic/custhome/${servername}/default

chmod 777 /mnt/distreplic/tmps/${servername}
chmod 775 /mnt/replicated/${servername}/confs/sites-available