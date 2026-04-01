#!/bin/bash
MSA=/usr/bin/mysqladmin
MARIADB_ROOT_PW=$1
apt update && apt upgrade && apt install mariadb-server php-mysql netcat-openbsd -y
set -u

# make sure ownership of data dir is OK
chown -R mysql:mysql /var/lib/mysql
/usr/bin/mysqld_safe &



sleep 5 # wait for mysqld_safe to rev up, and check for port 3306
port_open=0

while [ "$port_open" -eq 0 ]; do
   /bin/nc -z -w 5 127.0.0.1 3306
   if [ $? -ne 0 ]; then
       echo "Sleeping waiting for port 3306 to open: result " $? 
       sleep 1
   else
       echo "Port 3306 is open"
       port_open=1
   fi
done

# Secure the installation
done=0
count=0
maxtries=10
while [ $done -eq 0 ]; do
    ${MSA} -u root password ${MARIADB_ROOT_PW}
    if [ $? -ne 0 ]; then
        count=$((${count} + 1))
        if [ $count -gt $maxtries ]; then
            echo "Maximum tries at setting password exceeded. Giving up"
            exit 1
        else
            echo "Root password set failed. Sleeping, then retrying"
            sleep 1
        fi
    else
        echo "Root Password set successfully"
        done=1
    fi
done

# this code mimics the secure install script, which was originally
# scripted via expect. I found that unreliable, hence this section
CUSER="CREATE USER IF NOT EXISTS 'admin'@'%' IDENTIFIED BY '$MARIADB_ROOT_PW'" 
echo "$CUSER" | mysql -u root --password="$MARIADB_ROOT_PW"
CUSER="GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION"
echo "$CUSER" | mysql -u root --password="$MARIADB_ROOT_PW"

# drop test database
echo "Dropping test DB"
DROP="DROP DATABASE IF EXISTS test"
echo "$DROP" | mysql -u root --password="$MARIADB_ROOT_PW" 

echo "Cleaning test db privs"
# remove db privs for test
DELETE="DELETE FROM mysql.db Where Db='test' OR Db='test\\_%'"
echo "$DELETE" | mysql -u root --password="$MARIADB_ROOT_PW" 

echo "Deleting anon db users"
# remove anon users
DELETE="DELETE FROM mysql.user WHERE User=''"
echo "$DELETE" | mysql -u root --password="$MARIADB_ROOT_PW" 

echo "create mysql user"
# create mysql@localhost user for xtrabackup
CUSER="CREATE USER IF NOT EXISTS 'mysql'@'localhost'"
echo "$CUSER" | mysql -u root --password="$MARIADB_ROOT_PW" 

echo "FLUSH PRIVILEGES" | mysql -u root --password="$MARIADB_ROOT_PW" 

echo "Installation done !"