#!/bin/bash

#folders
mkdir -p /mnt/replicated/traefik/acme \
/mnt/replicated/helphp \
/mnt/replicated/pma \
/mnt/replicated/redis \
/mnt/replicated/maria-master \
/mnt/replicated/maria-slave \
/mnt/mysql-db/mysql/maria-master \
/mnt/mysql-db/logs/maria-master

cp confs/mysql/my-init.cnf /mnt/replicated/maria-master/ &&\
cp confs/mysql-slave/my-init.cnf /mnt/replicated/maria-slave/ &&\
cp confs/phpmyadmin/config.inc.php /mnt/replicated/pma/ &&\
cp -r confs/libretranslate /mnt/replicated/ &&\
cp mainstack.yml /mnt/replicated/

chmod -R 777 /mnt/replicated/libretranslate

git clone https://github.com/INRAI-helPHP/helPHP.git /mnt/replicated/helphp

echo "Folders and HelPHP libs ready"
