<img src="logo-border.svg" width="55%" />

# Installation Docker helphp

Vous avez déjà des conteneurs ou services en cours d'exécution (mysql au minimum quelque part) et vous voulez exécuter HelPHP dans un conteneur ?
pas de problème, vous pouvez déjà obtenir une image construite ou la construire vous-même.

Le principe :

![simple-container](/simple-container.png)

nous allons créer/utiliser un conteneur d'exécution qui montera les libs HelPHP, l'instance HelPHP, et les fichiers de configuration nécessaires pour contrôler tous les services à l'intérieur du conteneur.
Il sera connecté à un serveur DB, peut-être un NoSql comme redis, et un stockage pour stocker et manipuler des fichiers/dossiers.
Bien sûr ce conteneur peut être utilisé pour plusieurs instances HelPHP (cela dépend seulement de comment vous les montez, et de la configuration Apache) ou seulement une. C'est comme vous voulez.

Note : Que vous pouvez aussi utiliser les permissions utilisateur Linux à l'intérieur du conteneur (créer des utilisateurs dans votre conteneur et exporter /etc/passwd group shadow gshadow comme fichiers montables pour les fixer) pour séparer les instances et interdire les interactions entre comptes, dans ce cas faites attention à la constante "APACHE_USER" dans votre fichier de configuration principal.

Mais d'abord :

## Avez-vous Docker correctement installé ?

Si vous êtes sous Windows ou Mac, (parfois vous ne pouvez pas choisir...nous savons... nous savons), vous devez installer "Docker desktop" et ne pas utiliser le premier script (et adapter le second pour windows ou utiliser le terminal WSL).

Souvent, nous pouvons lire que docker fonctionne en tant que root, et c'est un problème de sécurité, oui c'est possible mais c'est aussi souvent une version ancienne et incomplète.
Donc d'abord nous devrions le vérifier :

- 1 vous devriez avoir git installé et être connecté en tant que super utilisateur.

```
sudo su
apt install git
```

- 2 clonez cette branche : 

```
git clone -b Docker https://github.com/INRAI-helPHP/helPHP-env-install
```

- 3 lancez le premier script d'installation pour installer correctement docker avec un utilisateur dédié (sélectionnez USER et PASSWORD bien sûr): 
```
cd helPHP-env-install
chmod 777 *-*.sh
./1-install-docker.sh USER PASSWORD
```
ce script créera aussi 3 dossiers et donnera les droits sur eux à l'utilisateur docker pour préparer la scalabilité (parce que ce n'est pas parce que nous exécutons seulement un conteneur sur un serveur, que ce sera encore le cas l'année prochaine) :

- /mnt/replicated : contiendra ce qui devrait être répliqué sur tous les nœuds dans un cluster
- /mnt/mysql-db : contiendra la DB mysql locale (parfois, si le cluster utilise une technologie de réplication comme glusterFS basée sur des blocs, il ne peut pas supporter la DB mysql, donc les fichiers DB sont répliqués par un autre mécanisme, comme master-slave ou une réplication via un cluster galera, donc les fichiers DB doivent être stockés à part).    
- /mnt/distreplic : contiendra les données qui sont distribuées sur un stockage de cluster mais non dupliquées sur tous les nœuds, mais toujours accessibles (gluster-fs ou ceph-node).

Bien sûr vous pouvez les ignorer et faire les étapes suivantes comme vous préférez, mais c'est bien de penser à l'évolution de votre architecture dès le début.

## Obtenir l'image :

Comme vous avez installé docker et défini un utilisateur dédié, connectez vous ("su") en tant que cet utilisateur avant de télécharger le conteneur.

Le conteneur d'exécution HelPHP existe déjà ici : [https://hub.docker.com/r/helphp/instance/]

Pour l'architecture Arm V7 / Arm V8 64 / Linux Amd x64 (donc il peut fonctionner sur la plupart des PC/Serveurs sous famille Debian, même un Raspberry).

pour obtenir l'image vous pouvez simplement utiliser `docker pull helphp/instance:latest`

si vous avez besoin de ffpmeg récupérez celle-ci à la place `docker pull helphp/instance:ffmpeg`

regardez les [tags] (https://hub.docker.com/r/helphp/instance/tags) si vous avez besoin d'une version plus ancienne.

donc, maintenant nous avons les images, vous pouvez directement sauter à la section "avant le lancement", ou regarder ce qu'il y a à l'intérieur dans ce qui suit ...

## Construire les images :

Construire ou reconstruire l'image peut permettre d'ajuster le contenu du conteneur et ses performances.

Si vous regardez dans Dockerfile, vous verrez que l'image de base est debian trixie.
Peut-être que vous utilisez une distro différente, mais ce qui est important c'est le noyau. 
Si la distro de base utilise le même noyau et architecture que votre serveur, les performances devraient être bonnes. 
En général les mauvaises performances avec docker viennent de cela, ou de problèmes de système de fichiers.

Si vous avez besoin d'une extension PHP ou d'autres outils, ou si vous voulez supprimer quelque chose dans notre sélection c'est le moment de modifier le Dockerfile.

Prêt ? donc sous votre compte utilisateur docker construisons-le :
`docker build -t helphp-instance .`
et nous le taguons (pour utiliser l'image locale au lieu de celle du docker hub):
`docker tag helphp-instance helphp/instance:latest`
après cela, si vous en avez besoin vous pouvez construire la version ffmpeg :
`docker build -t helphp-instance-ffmpeg -f Dockerfile-ffmpeg .`
et nous la taguons :
`docker tag helphp-instance-ffmpeg helphp/instance:ffmpeg`

## avant de lancer le conteneur
le premier script qui a installé docker, a aussi créé quelques dossiers pour préparer notre installation, donc d'abord nous avons besoin des libs HelPHP, et ces libs devraient être partagées entre tous les nœuds si nous créons un cluster un jour donc toujours en tant que votre utilisateur docker nous l'installerons dans le dossier "replicated" :
```
mkdir /mnt/replicated/helphp
git clone https://github.com/INRAI-helPHP/helPHP.git /mnt/replicated/helphp
```
parce que nous voulons faire les choses correctement, nous devrions aussi penser à comment nous gérerons les fichiers de configuration de notre conteneur, si vous regardez à l'intérieur du fichier "Dockerfile" vous avez vu que tous les fichiers de configuration importants ont été déplacés et symliés vers /opt/config/... 

c'est parce que nous voulons gérer la configuration conteneur par conteneur. 

Par exemple si vous exécutez un conteneur avec 10 instances helPHP à l'intérieur, qui sont routées par virtualhost apache et domaine, il est plus facile de gérer les fichiers de configuration s'ils sont à l'extérieur du conteneur, et aussi parce que vous devrez commiter chaque changement à votre conteneur et image... Cela deviendra rapidement difficile à maintenir. 

L'autre solution peut être d'utiliser un conteneur pour chaque instance, puis gérer les routes depuis un proxy inverse, mais vous consommerez des tonnes de ports et de ressources.

Pour certains projets vous devriez aussi vouloir adapter PHP.ini, ou ajouter des jails fail2ban etc etc, donc selon votre projet, il est mieux d'externaliser certains dossiers à l'extérieur du conteneur.

pour faire cela nous devrions préparer quelques dossiers dans /mnt/* selon leurs natures :
- fichiers de configuration : ils sont nécessaires sur chaque nœud à l'avenir -> /mnt/replicated
- fichiers home de l'instance, ou fichiers de données : ils devraient aller au stockage distribué -> /mnt/distreplic 

Longue explication ? oui bien sûr, mais exécution courte :

retournez en tant qu'utilisateur root et lancez le script numéro 2 comme cela : 

`./2-add-container.sh NAME_OF_MY_CONTAINER MY_DOCKER_USERNAME`

c'est fait ... il préparera les dossiers nécessaires et git clonera une instance HelPHP dans le dossier /mnt/distreplic/NAME_OF_MY_CONTAINER/custhome du conteneur
et il crée quelques dossiers et copie un tas de fichiers de configuration...(regardez à l'intérieur du script s'il vous plaît).

Et maintenant nous sommes prêts à lancer notre premier conteneur docker avec une instance HelPHP déjà installée ! (C'est tout ?)

## Lancer le conteneur
nous le lancerons simplement avec un lien vers les dossiers nécessaires, il fonctionnera jusqu'à ce que vous l'arrêtiez, même si vous redémarrez le serveur hôte.
Retournez à votre utilisateur docker (oui nous ne lançons pas de conteneur en tant que root ! comme ça votre conteneur ne peut pas être utilisé pour attaquer l'hôte en tant que root).
Remplacez NAME_OF_MY_CONTAINER par le nom de conteneur choisi précédemment (et le tag "latest" par "ffmpeg" si vous voulez la version ffmpeg) et copiez-collez cette longue ligne dans votre terminal (vous devriez faire un petit script avec cela):
```
declare containername="NAME_OF_MY_CONTAINER" && \
docker run --detach --rm --name ${containername} \
-p 80:80 \
-v /mnt/replicated/${containername}/confs:/opt/configs \
-v /mnt/distreplic/logs/${containername}:/var/log \
-v /mnt/distreplic/custhome/${containername}/default:/home/default \
-v /mnt/distreplic/tmps/${containername}:/tmp \
-v /mnt/replicated/helphp:/home/helphp \
helphp/instance:latest
```

Avant de tester si tout va bien, nous devrions définir les bons droits sur l'instance helphp et les libs core helPHP dans le dossier home de l'instance : 
`docker exec -ti NAME_OF_MY_CONTAINER chown -R www-data:users /home/default /home/helphp`

le port hôte 80 est redirigé vers le port interne 80 du conteneur, donc si vous tapez l'ip de l'hôte dans la barre d'adresse de votre navigateur vous devriez obtenir l'installateur final HelPHP.

En cas d'erreur, vous pouvez vérifier les logs dans /mnt/distreplic/logs et tester si apache fonctionne en tapant votre ip serveur + '/images/notif.mp3'.

dans ce cas il n'y a qu'une seule instance dans un conteneur. 
mais vous pouvez diviser le home du conteneur comme vous voulez et changer la config apache pour héberger plusieurs instances dans seulement un conteneur, ou vous pouvez multiplier les conteneurs et changer le port hôte pour gérer les routes vers eux selon un proxy inverse... 

maintenant qu'il est installé, nous pouvons faire quelques précisions sur notre premier schéma :

![simple-container-installed](/simple-container-installed.png)

Indiquant les volumes montés etc... 

et si vous avez installé Mysql et optionnellement Redis vous avez une solution fonctionnelle... 

Ok, mais si vous voulez gérer vos serveurs DB avec docker ? ou lancer d'autres conteneurs ???

Est-ce difficile à gérer ? 

Non parce que vous pouvez utiliser [Docker Compose](https://github.com/INRAI-helPHP/helPHP-env-install/tree/Compose).
