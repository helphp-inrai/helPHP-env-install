#!/bin/bash
apt-get -y install phpmyadmin
echo "Include /etc/phpmyadmin/apache.conf" >> /etc/apache2/apache2.conf
/etc/init.d/apache2 restart

echo "PMA installed"