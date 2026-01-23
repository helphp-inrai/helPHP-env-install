#!/bin/sh
FILE=/opt/usgroup/passwd
if test -f "$FILE"; then
   cp /opt/usgroup/* /etc/
fi

FCRON=/etc/crontab
if ! test  -f "$FCRON"; then
   touch /etc/crontab
fi

touch /etc/cron.*/*
crontab /etc/crontab
/etc/init.d/cron start
/etc/init.d/ssh start
/etc/init.d/php8.4-fpm start
echo "SetEnv HOST_HOSTNAME \"${HOST_HOSTNAME}\"" > /etc/apache2/dockhostname.conf
last="${HOST_HOSTNAME#${HOST_HOSTNAME%?}}"
echo "SetEnv MARIADB_SUFFIX \"${last}\"" >> /etc/apache2/dockhostname.conf
rm -f /var/run/apache2/apache2.pid
/usr/sbin/apache2ctl -D FOREGROUND

