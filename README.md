<img src="logo-border.svg" width="55%" />

# Introduction

After the [Docker](https://github.com/INRAI-helPHP/helPHP-env-install/tree/Docker) installation, and the [Compose](https://github.com/INRAI-helPHP/helPHP-env-install/tree/Compose) installation that are running on only one computer, we should study one cloud/cluster environment at last.
But before that there is a special case we must check with Compose : 
A compose stack with multiple mysql server. 

Why?

Data redondancy is now a principle in app creation (High Availibility): You should backup your data, but also being able to serve them even if one of your data server is off.
So first we have to take care about persitent data, there is two kind : Files and Databases.

For files, depending the cluster storage used, there is no real impact on the app dev, because from the FS aspect, a mounted storage is still a mounted storage. It can have some difference for block size calculation, performance or streaming issue, but nothing that a good HelPHP lib can resolve ;) .

For database, even if HelPHP offer a DB lib that support natively master/slave servers plus centralized user db server, you still need to test how your program react in this case, and switch DB server object target depending what your doing (i'm modifying a user ?  i'm using DB_CENTRAL db object, anything else ? $DB) ...

The centralized DB (DB_CENTRAL), is used when you're building multiple services/applications but you want mutualized user/group accounts. (you can use an external auth system, but it's in general more secured to rely on an internal one, and it's not forbidden to auto establish the connection with the internal when connecting with the external... Double security ;) ).

So we'll need a little compose stack with tree MySQL servers to make some tests. (if all is fine, it should work at minimum like the single MySQL server solution, with real servers you should get 2x speed up on reading operations).

## Let's continue...
In the previous branch for [Compose](https://github.com/INRAI-helPHP/helPHP-env-install/tree/Compose), we have finished a stack with a MySQL server, we should use the same stack and make some changes.

- 1 git clone this branch somewhere :
```
git clone -b Compose-multi-mysql https://github.com/INRAI-helPHP/helPHP-env-install
```

you'll find inside the previous files of the Compose branch and some usefull new files...

- 2 add some folders :

So we'll need to add some folders for all this services :

remember, in /mnt/ we have replicated , myslq-db and distreplic (if you have used script n°1).

If it's not already done, copy HelPHP :

```
mkdir /mnt/replicated/helphp
git clone https://github.com/INRAI-helPHP/helPHP.git /mnt/replicated/helphp
chown -R your_docker_username:users /mnt/replicated/helphp
```

we will create a MySQL server named "mymaria" and based on a classic version of mariaDB .

so under your docker user :

```
cd /mnt/
mkdir replicated/mymaria-slave \
mysql-db/mymaria-slave \
replicated/mymaria-central \
mysql-db/mymaria-central 
```

cd back in the helphp-env-install folder

```
cp confs/mysql-slave/my-init.cnf /mnt/replicated/mymaria-slave/ &&\
cp confs/mysql/my-init.cnf /mnt/replicated/mymaria-central/ &&\
cp compose-3-servers.yaml /mnt/replicated/
```

- 3 Edit compose-3-servers.yaml

With nano or any text editor, edit /mnt/replicated/compose-3-servers.yaml.

As for the compose stack you have to replace "YOUR.H.C.NAME" by the name you've given when you've launch the script 2-add-container.sh.

And to replace "YOURPASSWORD" by a choosen one for each MySQL server

- 4 some info about this stack :

you'll see if you compare with compose.yaml that there is few differences : 
the two first Mysql server boot as cluster and have a different my_init.cnf.
The slave one is interesting :

you'll find two important values :
server-id=2
auto_increment_increment = 2

server id to make the difference with the master (id 1) and the auto_increment in case we reverse the writing order or create a cluster with double master slave replication (so if both server write someting, they'll not use same id for writing simoultaneously), of if the master is dead and we should reverse write to a new sql server.

PhPmyadmin will take care of the 3 MySQL server now.

- 5 HelPHP configuration 

Two case there : 

1 - you still haven't install HelPHP? 
so when you'll visit your_ip in your browser you'll be able to the installscript formular and fill it...

2 - It's already installed ? 
You must make some modification configuration
got to your instance config folder (normaly in a path like this : /mnt/distreplic/custhome/YOUR.H.C.NAME/default/config") and edit db.php to modify some constants :
```
    const MASTER_SLAVE_MODE = true;
    const DB_SLAVE_HOST = 'mymaria-slave';
    const DB_SLAVE_USER = 'YOURUSER';
    const DB_SLAVE_BASE = 'YOURDB';
    const DB_SLAVE_PASS = 'YOURPASSWORD';
    
    const DB_CENTRAL = true;
    const DB_CENTRAL_HOST = 'mymaria-central';
    const DB_CENTRAL_USER = 'YOURUSER';
    const DB_CENTRAL_BASE = 'YOURDB';
    const DB_CENTRAL_PASS = 'YOURPASSWORD';  
```
of course change YOURUSER, YOURDB, YOURPASSWORD...

Then open a bash session in your running instance container :
(before type `docker ps` to get your container id).
```
docker exec -it yourcontainerid bash
``` 

Once connected, cd in /home/helphp/utils and launch :

```
php install_db_and_modules.php /HOMEOFYOURINSTANCE
```
(normaly /home/default if you'r still with the default instance example of compose branch).


it should launch the master slave replication et install the user db in mymaria-central. 

Finaly, with phpmyadmin, copy the content of the 'group_data','group_users','users_address','users_connexions','users_data' tables from master/slave to central, and your instance should run exactly like before, but in master/slave mode + centralized DB. 

## Launch it !
Still as your docker user, first down the previous compose if it's still up :
`docker compose down`

then launch the new composition :
`docker compose -f compose-3-servers.yaml up`

go to your navigator and type your server ip adress (localhost or 127.0.0.1 if it's your computer) to start helphp instance install or + ":8001" to go to phpmyadmin.

You should get something running fluently, with nearly no difference and that can still run on only one machine.

And you can switch back to the previous compose.yaml depending your needs.

Evolution of our stack :

![compose-multi.png](compose-multi.png)

Now if you want to experiment with file storage and network communication in a cluster/cloud you'll need at last 2 server or 2 VM to create a docker [Swarm](https://github.com/INRAI-helPHP/helPHP-env-install/tree/Swarm) (3 if you want to play with Kubernetes, but Swarm and 2 server are enough for our needs). 

If you have only one PC for experimentation, take a look on VirtualBox, VMWare, Promox etc... there is tons of good virtualization software. 

