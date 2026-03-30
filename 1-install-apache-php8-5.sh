#!/bin/bash
echo "updating system"
apt-get update --fix-missing && apt-get -y upgrade

## install some basic host utils...
echo "install basic utils"
apt-get install -y --no-install-recommends apt-utils whois lsb-release ca-certificates apt-transport-https gnupg2 wget

## Install  PHP and stuff
#php repository
echo "setup php repository"
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main"  > /etc/apt/sources.list.d/php.list
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
apt-get update

echo "install PHP 8.5 and Apache + modules and some security stuff"
#default container can connect to mysql or mariadb, if you want postgress or another, add it's extension there
apt-get -y --no-install-recommends install \
ssh \
apache2 \
libapache2-mod-fcgid \
libapache2-mod-security2 \
fail2ban \
openssl \
libssl-dev \
procps \
git \
htop \
fail2ban \
php8.5 \
php8.5-zip \
php8.5-fpm \
php8.5-cli \
php8.5-common \
php8.5-curl \
php8.5-gd \
php8.5-ssh2 \
php8.5-intl \
php8.5-mysql \
php8.5-redis \
php8.5-mbstring \
php8.5-xml \
php8.5-soap \
apparmor \
mcrypt \
openssl \
nano \
mariadb-client \
iputils-ping \
locales \
p7zip-full \
rsync \
pv \
wget curl \
cron \
logrotate \
apache2-utils

#adding some locale, you can add yours here... 
echo "adding EN US DE ES FR locales"
locale-gen en_US.UTF-8 en_GB.UTF-8 de_DE.UTF-8 es_ES.UTF-8 fr_FR.UTF-8

#activating some apache module
echo "activating Apache modules"
a2enmod rewrite expires headers setenvif proxy_fcgi http2 && \
a2enconf php8.5-fpm

#some modificiation in local cli and fpm default config files if we do not use mounted ones
echo "fixing a bit php config"
sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php/8.5/fpm/php.ini && \
sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php/8.5/fpm/php.ini  && \
sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php/8.5/cli/php.ini && \
sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php/8.5/cli/php.ini

echo "fixing Apache env vars"
export APACHE_RUN_USER=www-data
export APACHE_RUN_GROUP=www-data
export APACHE_LOG_DIR=/var/log/apache2
export APACHE_LOCK_DIR=/var/lock/apache2
export APACHE_PID_FILE=/var/run/apache2.pid

#moving configs in /opts to able to mount custom ones later
echo "moving all importants config files and folder to /opt/config"
mkdir -p /opt/configs && \
mv /etc/apache2/sites-available /opt/configs/ && \
mv /etc/apache2/apache2.conf /opt/configs/apache2.conf && \
mv /etc/apache2/mods-available/mpm_event.conf /opt/configs/mpm_event.conf && \
mv /etc/php/8.5/fpm/php.ini /opt/configs/php.ini && \
mv /etc/php/8.5/fpm/pool.d/www.conf /opt/configs/www.conf && \
mv /etc/php/8.5/cli/php.ini /opt/configs/php-cli.ini && \
mv /etc/fail2ban/jail.conf /opt/configs/jail.conf && \
mv /etc/logrotate.d /opt/configs && \
ln -s /opt/configs/logrotate.d /etc/logrotate.d && \
ln -s /opt/configs/sites-available /etc/apache2/sites-available && \
ln -s /opt/configs/apache2.conf /etc/apache2/apache2.conf && \
ln -s /opt/configs/mpm_event.conf /etc/apache2/mods-available/mpm_event.conf && \
ln -s /opt/configs/php-fpm.ini /etc/php/8.5/fpm/php.ini && \
ln -s /opt/configs/www.conf /etc/php/8.5/fpm/pool.d/www.conf && \
ln -s /opt/configs/php-cli.ini /etc/php/8.5/cli/php.ini && \
ln -s /opt/configs/jail.conf /etc/fail2ban/jail.conf

## do you need a user to commmunicate with the container thru ssh internaly in your network ? exemple commmand :
#RUN useradd -g users 'USER' -p `mkpasswd 'password'` && mkdir -p /home/'USER'/ && chown 'USER':www-data /home/'USER'
echo "cleaning\n"
rm -rf /var/lib/apt/lists/* && \
apt-get purge   --auto-remove && \
apt-get clean

echo "setting up starting services"
mkdir -p /etc/service/_start
mv start.sh /etc/service/_start/run
chmod 777 /etc/service/_start/run
mv shstart.service /etc/systemd/system/shstart.service
systemctl daemon-reload
systemctl enable shstart.service
systemctl enable php8.5-fpm
systemctl enable fail2ban
update-alternatives --set php /usr/bin/php8.5
echo "8.5" > /root/preferred_php_cli.version

echo "Apache and PHP installed, now check if you need installer n°2 for Mysql Server\n"