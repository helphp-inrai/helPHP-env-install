# Modification history / What's new ?

This file list all the modification we made, classified by commit, if you can fix your installation with a simple git pull (in general it's because we made structural changes!).
Each time you see "commit xxx" thats mean all the modification below are inside these commit. 

# 2026_03_25 
PHP 8.5 version of the docker container !
If you upgrade from the 8.4 version :
remove opcache.ini in your instance confs folder
still in confs modify www.conf and change "listen = /run/php/php8.4-fpm.sock" to "listen = /run/php/php8.5-fpm.sock"  