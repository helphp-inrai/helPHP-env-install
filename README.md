<img src="logo-border.svg" width="55%" />

# helphp Docker install

You have already some container or services running (mysql at minimum somewhere) and you want to run HelPHP in a container?
no problem, you can already get a builded image or build it yourself. 

The principle :

![simple-container](/simple-container.png)

we'll create/use an execution container that will mount HelPHP libs, HelPHP instance, and the config files necessary to control all services inside the container.
It will be connected to a DB server, perhaps a NoSql one like redis, and a storage to store and manipulate files/folders. 
Of course this container can be used for multiple HelPHP instance (it depends only how you mount them, and the Apache configuration) or only one. It's as you wish.

Note : That you can also use Linux user permission inside the container (create users in your container and export /etc/passwd group shadow gshadow as mountable files to fix them ) to separate instances and forbib interaction between accounts, in that case be careful of the "APACHE_USER" constant in your main config file.

But first :

## Do you have Docker correctly installed ?

If you are under Windows or Mac, (sometimes you can't choose...we know... we know), you need to install "Docker desktop" and don't use the first script (and adapt the second for windows or use WSL terminal).

Often, we can read that docker is running as root, and that's a security issue, yes it's possible but also it's often an old and incomplete version.
So first we should check it :

- 1 you should have git installed and be loged as super user.

```
sudo su
apt install git
```

- 2 clone this branch : 
```
git clone -b Docker https://github.com/INRAI-helPHP/helPHP-env-install
```
- 3 launch the first install script to correctly install docker with a dedicated user (select USER and PASSWORD of course): 
```
cd helPHP-env-install
chmod 777 *-*.sh
./1-install-docker.sh USER PASSWORD
```
this script will also create 3 folders and give rights on them to the docker user to prepare scalability (because it's not because we run only one container on one server, that it still be the case next year ) :

- /mnt/replicated : will contain what should be replicated on all node in a cluster
- /mnt/mysql-db : will contain local mysql DB (sometimes, if the custer use replication technology like glusterFS based on blocks, it can't support mysql DB, so the DB files are replicated by other mecanism, like master-slave or galera cluster replication, so the DB files must be stored appart).    
- /mnt/distreplic : will contain data that are distributed on a cluster storage but not duplicated on all nodes but still accessible (gluster-fs or ceph-node).

Of course you can ignore them and make the following steps as you prefer, but it's good to think about the evolution of your architecture from the very beggining.

## Get the image :

As you've installed docker and set a dedicated user, connect ("su") as this user before getting the container.

The HelPHP execution container already exist here : [https://hub.docker.com/r/helphp/instance/]

For architecture Arm V7 / Arm V8 64 / Linux Amd x64  (so it can run on most of any PC/Server under Debian family, even a Raspberry).

to get the image you can simply use `docker pull helphp/instance:latest`

if you need ffpmeg pull this one instead `docker pull helphp/instance:ffmpeg`

look at the [tags] (https://hub.docker.com/r/helphp/instance/tags) if you need an older version.

so, now we have the images, you can directly jump to the "before launching" section, or take a look about what's inside in the following ...

## Build the images :

Building or rebuilding the image can permit to adjust the container content and its performances.

If you take a look in Dockerfile, you'll see that the image base is debian trixie.
Perhaps you're using a different distro, but what's important is the kernel. 
If the base distro use the same kernel and architecture as your server, the performances should be good. 
In general bad performances with docker comes from that, or filesystem issue.

If you need some PHP extension or any other tools, or if you want to remove something in our selection it's the moment to modify the Dockerfile.

Ready ? so under your docker user account let's build it :
```
docker build -t helphp-instance .
```
and we tag it (to use the local image instead of the docker hub one):
```
docker tag helphp-instance helphp/instance:latest
```
after that, if you need you can build the ffmpeg version :
```
docker build -t helphp-instance-ffmpeg -f Dockerfile-ffmpeg .
```
and we tag it :
```
docker tag helphp-instance-ffmpeg helphp/instance:ffmpeg
```
## before launching the container
the first script that installed docker, create also some folders to prepare our installation, so first we need HelPHP libs, and those libs should be shared between all nodes if we create a cluster one day so still as your docker user we'll install it in the "replicated" folder :
```
mkdir /mnt/replicated/helphp
git clone https://github.com/INRAI-helPHP/helPHP.git /mnt/replicated/helphp
```
because we want to do things correctly, we should also think about how we'll manage the config files of our container, if you take a look inside the file "Dockerfile" you've seen that all important config files have been moved and symklinked to /opt/config/... 

that's because we want to manage the configuration container by container. 

For exemple if you run one container with 10 helPHP instances inside, that are routed by apache virtualhost and domain, it's easier to manage config files if they are outside the container, and also because you'll have to commit each change to your container and image... It will quickly become difficult to maintain. 

The other solution can be to use one container for each instance, then manage route from a reverse proxy, but you'll consume tons of ports and ressource.

For some project you should also want to adapt PHP.ini, or add some fail2ban jail etc etc, so depending you project, it's better to externalize some folders outside the container.

to do that we should prepare some folders in /mnt/* depending their natures :
- configuration files : they are needed on each node on the future -> /mnt/replicated
- home files of the instance, or data files : they should go to the distributed storage -> /mnt/distreplic 

Long explanation ? yes sure, but short execution :

go back as root user and launch the script number 2 like that : 

```
./2-add-container.sh NAME_OF_MY_CONTAINER MY_DOCKER_USERNAME
```

that's it ... it will prepare the needed folders and will git clone a HelPHP instance in /mnt/distreplic/NAME_OF_MY_CONTAINER/custhome folder of the container
and it create some folders and copy a bunch of config files...(take a look inside the script please).

And now we're ready to launch our first docker container with a HelPHP instance already installed ! (W...F ?)

## Launching the container
we'll simply launch it and mount the needed folders, it will run until you stop it, even if you reboot the host server.
go back to your docker user (yes we don't launch container as root user ! like that your container can't be superelavated and used to attack the host as root).
Replace NAME_OF_MY_CONTAINER by your previous choosen container name (and "latest" tag by "ffmpeg" if your want ffmpeg version) and copy paste this long line in your terminal (you should make a little script with it):
```
declare containername="NAME_OF_MY_CONTAINER" && \
docker run --detach --rm --name ${containername} \
-p 80:80 \
-v /mnt/replicated/${containername}/confs:/opt/configs \
-v /mnt/distreplic/logs/${containername}:/var/log \
-v /mnt/distreplic/custhome/${containername}:/home/default \
-v /mnt/distreplic/tmps/${containername}:/tmp \
-v /mnt/replicated/helphp:/home/helphp \
helphp/instance:latest
```

Before testing if all y ok, we should set the good rights on the helphp Instance and helPHP core libs in home folder of the instance : 
```
docker exec -ti NAME_OF_MY_CONTAINER chown -R www-data:users /home/default /home/helphp
```

the host port 80 is redirected to the internal port 80 of the container, so if you type the ip of the host in your navigator adress bar you should get the HelPHP final installer.

In case of error, you can check the logs in /mnt/distreplic/logs and test if apache work by typing your server ip + '/images/notif.mp3'.

in this case there is only one instance in one container. 
but you can divide the home of the container as you want and change apache config to host multiple instance in only on container, of you can multiply the containers and change the host port to manage the routes to them depending a reverse proxy... 

now as it's installed, we can make some precisions on our first schema :

![simple-container-installed](/simple-container-installed.png)

Indicating the volume mounted etc... 

and if you've installed Mysql and optionnaly Redis you have a working solution... 

Ok, but if you want to manage your DB servers with docker ? of launch other container ???

Will it be difficult to manage ? 

No because you can use [Composer](https://github.com/INRAI-helPHP/helPHP-env-install/tree/Composer).



