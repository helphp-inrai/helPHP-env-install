<img src="logo-border.svg" width="55%" />

# One line install ... On what ?

if you have a server or a VM running a recent Debian, Ubuntu or Mint like linux ouf of the box with nothing installed, log in as root/sudo user and copy paste this command :

```
apt install -y git && \
git clone -b Compose https://github.com/INRAI-helPHP/helPHP-env-install && \
bash helPHP-env-install/one_line_install.sh
```
it will ask for a username and password to create a user dedicated to docker and to launch HelPHP services, a name for your HelPHP container, and finaly the root password for your SQL MariaDB server.

When ended, you'll find in /mnt/replicated a file named launch.sh .

Log in as your new user (su username) and launch the script : /mnt/replicated/launch.sh 

then in your navigator, type http://+the ip adress of your server or VM and you should get the HelPHP installer page.

Enjoy ;)

you can edit you HelPHP instance in /mnt/distreplic/custhome/NAME_OF_YOUR_CONTAINER/default
you can tail the logs in /mnt/distreplic/logs/NAME_OF_YOUR_CONTAINER/...
and your HelPHP libs repository is in /mnt/replicated/helphp

interested in what was done on your server ? Please check [Compose](https://github.com/INRAI-helPHP/helPHP-env-install/tree/Compose) branch.
