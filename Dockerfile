#Dockerfile for executing HelPHP projects
#done and maintained by myke moi@myke666.fr
#to build it : docker build -t helphp-instance .

FROM debian:trixie-slim

#basic repo update

RUN apt update --fix-missing && apt-get -y upgrade
## install some basic host utils...
RUN apt install -y --no-install-recommends apt-utils whois lsb-release ca-certificates apt-transport-https gnupg2 wget

# Install  PHP and stuff
#php repository
RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main"  > /etc/apt/sources.list.d/php.list
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
RUN apt update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install \
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
php8.4 \
php8.4-zip \
php8.4-fpm \
php8.4-cli \
php8.4-common \
php8.4-curl \
php8.4-gd \
php-ssh2 \
php8.4-intl \
php8.4-mysql \
php8.4-opcache \
php8.4-redis \
php8.4-mbstring \
php8.4-xml \
php8.4-soap \
apparmor \
mcrypt \
openssl \
nano \
#default container can connect to mysql or mariadb, if you want postgress or another, add it's extension there
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
RUN locale-gen en_US.UTF-8 en_GB.UTF-8 de_DE.UTF-8 es_ES.UTF-8 fr_FR.UTF-8

#activating some apache module
RUN a2enmod rewrite expires headers setenvif proxy_fcgi http2 && \
a2enconf php8.4-fpm

#some modificiation in local cli and fpm default config files if we do not use mounted ones
RUN sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php/8.4/fpm/php.ini && \
sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php/8.4/fpm/php.ini  && \
sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php/8.4/cli/php.ini && \
sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php/8.4/cli/php.ini


ENV APACHE_RUN_USER=www-data
ENV APACHE_RUN_GROUP=www-data
ENV APACHE_LOG_DIR=/var/log/apache2
ENV APACHE_LOCK_DIR=/var/lock/apache2
ENV APACHE_PID_FILE=/var/run/apache2.pid

#moving configs in /opts to able to mount custom ones later
RUN mkdir -p /opt/configs && \
mv /etc/apache2/sites-available /opt/configs/ && \
mv /etc/apache2/apache2.conf /opt/configs/apache2.conf && \
mv /etc/apache2/mods-available/mpm_event.conf /opt/configs/mpm_event.conf && \
mv /etc/php/8.4/mods-available/opcache.ini /opt/configs/opcache.ini && \
mv /etc/php/8.4/fpm/php.ini /opt/configs/php.ini && \
mv /etc/php/8.4/fpm/pool.d/www.conf /opt/configs/www.conf && \
mv /etc/php/8.4/cli/php.ini /opt/configs/php-cli.ini && \
mv /etc/fail2ban/jail.conf /opt/configs/jail.conf && \
mv /etc/logrotate.d /opt/configs && \
ln -s /opt/configs/logrotate.d /etc/logrotate.d && \
ln -s /opt/configs/sites-available /etc/apache2/sites-available && \
ln -s /opt/configs/apache2.conf /etc/apache2/apache2.conf && \
ln -s /opt/configs/mpm_event.conf /etc/apache2/mods-available/mpm_event.conf && \
ln -s /opt/configs/opcache.ini /etc/php/8.4/mods-available/opcache.ini && \
ln -s /opt/configs/php-fpm.ini /etc/php/8.4/fpm/php.ini && \
ln -s /opt/configs/www.conf /etc/php/8.4/fpm/pool.d/www.conf && \
ln -s /opt/configs/php-cli.ini /etc/php/8.4/cli/php.ini && \
ln -s /opt/configs/jail.conf /etc/fail2ban/jail.conf

## do you need a user to commmunicate with the container thru ssh internaly in your network ? exemple commmand :
#RUN useradd -g users 'USER' -p `mkpasswd 'password'` && mkdir -p /home/'USER'/ && chown 'USER':www-data /home/'USER'

RUN rm -rf /var/lib/apt/lists/* && \
apt purge --auto-remove && \
apt clean

EXPOSE 80
RUN mkdir -p /etc/service/_start
ADD start.sh /etc/service/_start/run
RUN chmod 777 /etc/service/_start/run
RUN systemctl enable php8.4-fpm
RUN systemctl enable fail2ban
RUN update-alternatives --set php /usr/bin/php8.4
RUN echo "8.4" > /root/preferred_php_cli.version

CMD ["/etc/service/_start/run"]
