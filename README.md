<img src="logo-border.svg" width="55%" />

# helphp LAMP Install

This branch describe how to install HelPHP with a classic LAMP stack.
we will install HelPHP libs and one HelPHP instance, but you can of course run multiple instances (it all depends your Apache configuration.).
Note that you can also use Linux user permission to divide instances and forbib interaction between accounts, in that case be careful of the "APACHE_USER" constant in your main config file. 

## The server

We choose a debian 13 for this installation, nearly all debian family (ubuntu, mint etc), can use directly this guide without any modification.
For other distro, you'll need to adapt the different sh scripts (rpm instead deb apt etc). but the logic is the same. 
(if you want to contribute and push an install adapted for your favorite distro, dont hesitate to let a `suggestion` in the issues board)

## Let's go to install the stuff :
- 1 you should have git installed and be loged as super user.

```
sudo su
apt install git
```


- 2 clone this branch : 
```
git clone -b LAMP https://github.com/INRAI-helPHP/helPHP-env-install
```
- 3 launch the first install script to get Apache and PHP-FPM 8.5 : 
```
cd helPHP-env-install
chmod 777 *-*.sh
./1-install-apache-php8-5.sh
```

- 4 testing : if you type the ip of your server in your navigator adress bar you should get the Apache default Page.

- 5 Do we need a Mysql server on the same server ? 
If yes, to install MariaDB (a great mysql server), go back to helphp-env-install Choose a correct password for your mysql root/admin user folder and run :
```
./2-install-mariadb.sh YOUR_PASSWORD 
```
- 6 Do you need PhpMyAdmin ?
still in helphp-env-install launch :
```
./3-install-pma.sh
```

during the installation, select "apache" as web server and confirm that you want to configure phpmyadmin with dbconfig-common. You can also select a pass for phpmyadmin db or let it random.

After that in the adress bar of your navigator you can type the ip of your server followed by "/phpmyadmin" 
and access to phpmyadmin and inspect your Mariadb server with user root and your password specified at step 5.

- 7 Do you need ffmpeg for video encoding ?
```
./4-install-ffmpeg.sh
```

- 8 Do you need Redis (for fast session and process following mutualisation ?).
```
./5-install-redis.sh`
```
- 9 Clone HelPHP and its instance : 
go to the folder where you want to install HelPHP libs and clone it there :
```
git clone https://github.com/INRAI-helPHP/helPHP
```

then we'll clone the instance in default apache served directory :
```
cd /var/www/html
rm *
git clone https://github.com/INRAI-helPHP/helPHP-instance /var/www/html
chown -R www-data:www-data /var/www/html/
cd ..
mkdir data
chown www-data:www-data data
```
the /var/www/data folder will be used to store data manipulated by helPHP filesystem .
Take care to check your instance config then in your navigator adress bar type your server ip and you should get the HelPHP final installer.

if you want autotranslation for UI and content, you should check the [Compose](https://github.com/INRAI-helPHP/helPHP-env-install/tree/Compose) version, or install libretranslate as a docker container but not directly on same server instance as its really consuming ressource.




