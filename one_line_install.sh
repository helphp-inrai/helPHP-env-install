#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

owner=$(who am i | awk '{print $1}')
if [ "$(whoami)" != 'root' ];
    then
        echo $"You have no permission to run $0 as non-root user. Use sudo"
        exit 1;
fi
echo "---Installing Docker and creating its dedicated user :"
read -p "Enter the Docker username: " username
read -p "Enter its password : " password
cd helPHP-env-install
bash $SCRIPT_DIR/1-install-docker.sh $username $password

echo "---Preparing launch of the HelPHP Docker container :"
mkdir /mnt/replicated/helphp
git clone https://github.com/INRAI-helPHP/helPHP.git /mnt/replicated/helphp
chown -R $username:www-data /mnt/replicated/helphp
read -p "Enter a name for your HelPHP container: " container
bash $SCRIPT_DIR/2-add-container.sh $container $username

echo "---Preparing launch of Mariadb, Redis and libretranslate Docker container :"
mkdir /mnt/replicated/redis /mnt/replicated/pma /mnt/replicated/mymaria /mnt/mysql-db/mymaria 
cp $SCRIPT_DIR/confs/mysql/my-init.cnf /mnt/replicated/mymaria/
cp $SCRIPT_DIR/confs/phpmyadmin/config.inc.php /mnt/replicated/pma/
cp $SCRIPT_DIR/compose.yaml /mnt/replicated/
cp -r $SCRIPT_DIR/confs/libretranslate /mnt/replicated/
chmod -R 777 /mnt/replicated/libretranslate
cp $SCRIPT_DIR/compose.yaml /mnt/replicated/
chown -R $username:www-data /mnt/replicated/compose.yaml
read -p "Select a root password for MariaDB: " mysqlpass
sed -i "s/YOUR.H.C.NAME/$container/" /mnt/replicated/compose.yaml
sed -i "s/YOURPASSWORD/$mysqlpass/" /mnt/replicated/compose.yaml

touch /mnt/replicated/launch.sh
echo "docker compose up --detach" >> /mnt/replicated/launch.sh
chmod +x /mnt/replicated/launch.sh
chown $username:users /mnt/replicated/launch.sh
echo "---FINISHED ! you just need to launch /mnt/replicated/launch.sh with your new Docker user!"
