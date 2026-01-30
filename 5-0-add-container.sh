#!/bin/bash
read -p "Enter a name for your HelPHP container: " container
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
mkdir -p /mnt/replicated/${container}/confs
mkdir -p /mnt/distreplic/logs/${container}/apache2
mkdir -p /mnt/distreplic/custhome/${container}/default
mkdir -p /mnt/distreplic/tmps/${container}
cp -r "$SCRIPT_DIR/confs/helphp-instance/"* /mnt/replicated/${servername}/confs/

git clone https://github.com/INRAI-helPHP/helPHP-instance.git /mnt/distreplic/custhome/${container}/default

chown -R www-data:www-data /mnt/replicated/${container}/* /mnt/distreplic/custhome/${container} /mnt/distreplic/tmps/${container} /mnt/distreplic/custhome/${container}/default
chown -R www-data:www-data  /mnt/distreplic/logs/${container}
chmod 777 /mnt/distreplic/tmps/${container}
chmod 775 /mnt/replicated/${container}/confs/sites-available

sed -i "s/MYCONTAINER/$container/" /mnt/replicated/mainstack.yml

read -p "Select a root password for MariaDB: " mysqlpass
sed -i "s/YOURPASSWORD/$mysqlpass/" /mnt/replicated/mainstack.yml

echo "Done ! you're ready to launch your stack"





