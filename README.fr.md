<img src="logo-border.svg" width="55%" />

# helphp-env-install avec Docker Swarm !

Dans cette branche nous allons rencontrer ... LE SWAAAAARRRRMMM !!!!

N'ayez pas peur, le swarm est votre ami !

Quand vous installez Docker, il vient avec compose, mais aussi avec le swarm : Si compose permet de gérer plusieurs services sur un serveur/VM, le swarm fait la même chose sur plusieurs serveurs/VM et permet de créer un vrai cloud avec haute disponibilité, équilibrage de charge etc...

Pourquoi choisissons-nous Docker swarm au lieu de Kubernetes ? Il y a quelques différences mais, en fait, Swarm est plus simple et consomme moins de ressources.

KB est vraiment fait pour les projets gigantesques avec des tonnes de serveurs et de micro services, en général Docker Swarm suffit et on peut commencer avec seulement deux serveurs/VM, KB en a besoin de trois. Et si nécessaire vous pouvez migrer vers KB plus tard.

Quand nous disons que Docker Swarm est plus simple que KB, vous pourrez l'apprécier avec ce projet, parce que nous allons installer la pile cluster/cloud la plus simple possible avec un minimum de services et de sécurité et cela ressemble déjà à ça :

![swarm.png](swarm.png)

Qu'est-ce que c'est que cette étrange créature ?

## Comprendre l'architecture

- Communications :

En bleu clair vous avez nos serveurs A et B, ils ont une ou deux cartes réseau chacun. 

Si vos serveurs/VM ont deux cartes nous pouvons isoler les communications internes avec un Vlan et laisser seulement les services frontaux afficher/communiquer via la première. 

C'est vraiment mieux d'avoir deux cartes, parce que les communications internes ne sont pas exposées via le réseau public, et la bande passante de votre serveur pour le réseau public n'est pas consommée par les services internes.

Sur le schéma, les transferts publics sont en vert et communiquent via un réseau configuré comme bridge.
Les liens violets sont pour les communications internes et sont juste un Vlan interne, pas exposé au public.

Comme il y a deux serveurs, si nous voulons attacher un Domaine aux deux, nous aurons besoin d'un load balancer externe, ou au moins d'un DNS avec déclaration round robin des deux serveurs.

- Stockages :
en gris vous avez les stockages :
Vous trouverez à nouveau nos dossiers replicated / distreplic / mysql-db mais cette fois configurés comme stockage partagé et répliqué sur les deux serveurs (sauf mysql-db) avec gluster-FS.

Gluster fs peut répliquer un stockage sur tous les serveurs/vm ou distribuer les données au travers d'un stockage distribué, avec des blocs multipliés 2 ou X fois (donc si vous avez 5 serveurs avec 1Tb pour gluster FS distribué, et vous définissez 2 copies pour les blocs, vous avez en fait 2.5Tb de stockage disponible).
Donc avec GlusterFS, quand vous écrivez quelque chose sur le serveur A, vous trouverez la même chose sur le serveur B.

Mais les stockages de blocs ne sont pas faits pour les bases de données mysql, donc elles devraient être stockées différemment.
Localement, avec une réplication de données via le système de réplication MariaDB/MySQL Master/Slave.

- Services :
sur chaque serveur nous allons installer docker Swarm, qui fusionnera les ressources des deux serveurs et permettra de lancer des services sur les deux serveurs selon les ressources disponibles. Mais certains services doivent être présents sur tous les serveurs, certains non.

En orange vif, vous avez les serveurs MariaDB, qui effectueront les opérations mysql sur la DB mysql locale. Et comme ils sont locaux, les services mysql doivent être attachés à la DB correspondante et donc lancés à  chaque fois sur le même serveur.

En orange clair, certains services qui peuvent être lancés n'importe où. Docker swarm choisira le meilleur serveur pour les lancer selon les ressources disponibles (Phpmyadmin, Libretranslate, Redis)

En jaune, les services qui devraient être disponibles sur tous les serveurs : Traefik pour le proxy inverse, équilibrage, filtrage de sécurité etc, et notre conteneur d'exécution HelPHP.

- Principes : 

si vous demandez quelque chose au conteneur HelPHP sur le serveur A ou B, le résultat est le même, parce que la base de données est répliquée, mais aussi le stockage, et même les sessions gérées par redis.

Si vous lisez/streamez des données en alternant les requêtes vers A/B, vous doublez simplement la vitesse de transfert (en théorie !)

Si vous écrivez quelque chose en base de données, la vitesse est limitée par le serveur A qui héberge le serveur mysql master.

Si vous uploadez un fichier, la vitesse peut être doublée si vous le chunkez (l'API HelPHP via la lib FS offre cette fonctionnalité) et envoyez deux chunks en même temps.

Si un serveur est hors service, l'autre s'occupera de tout parce que le swarm détectera la mort d'un serveur dans son cluster et redistribuera les services sur le survivant.
Dans ce cas, si vous avez un load balancer externe en front ou des serveurs avec détection de panne, vos services continueront à fonctionner comme si de rien n'était (juste un peu plus lent). Si vous utilisez l'astuce du DNS en "round robin", vous devrez supprimer l'ip du serveur mort de celui-ci et cela fera la même chose. 

Si vous avez besoin de plus de ressources, ajoutez un serveur, faites-le rejoindre le swarm, étendez votre stockage gluster, et c'est tout... et continuez à étendre votre créature... 

Il est VIVANT !!! VIVANT !!! (huuuh désolé...)

## Prêt ? Allez installer cette créature

- 0-0 : Quelques tâches de préparation :

D'abord connectez-vous aux deux serveurs/VM et sudo en root, cd dans n'importe quel dossier que vous voulez et :

```
apt install git -y && git clone -b Swarm https://github.com/INRAI-helPHP/helPHP-env-install \
&& cd helPHP-env-install \
&& chmod 777 *.sh \
&& bash 0-0-background-sh
```

- 0-1 : Configuration Vlan 
Si vous avez une carte réseau secondaire sur chaque serveur juste liée à un switch ou un Vlan sans DHCP, nous pouvons créer un réseau interne pour la communication avec des ip fixes .

Veuillez noter qu'après cette étape quand nous parlons du réseau interne ou ip, cela se référera aux ips choisies pendant cette étape, ou l'ip de votre carte réseau unique (nous ferons fonctionner cette créature même s'il n'y a qu'une carte réseau).

Donc d'abord nous devons découvrir le nom de notre carte réseau :

`ip a ` affichera la configuration réseau actuelle avec une carte déjà connectée avec l'ip que vous utilisez pour la connexion terminal ssh et une secondaire, veuillez noter son nom et lancer 

`./0-1-vlan.sh`

répondez à la première question avec le nom que vous venez de noter, et à la seconde entrez une ip compatible avec votre Vlan ou réseau, par exemple 168.168.2.1 sur le premier serveur et .2 sur le second.

Normalement l'on devrait pouvoir ping l'autre serveur/VM via son ip (assurez-vous que cela fonctionne avant de continuer)

nous allons modifier /etc/hosts pour associer ces ips avec un nom pour la communication entre les deux serveurs/VM, donc :

`nano /etc/hosts`

et ajoutez l'ip de l'autre serveur et un nom comme cluster-2
et après 127.0.0.1 ajoutez aussi un nom pour identifier le serveur actuel.

vous devriez obtenir pour le serveur quelque chose comme cela : 

```
127.0.0.1       localhost   cluster-1
192.168.2.2     cluster-2
# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

donc quand nous appelons un serveur "cluster-X", la communication passe seulement sur le réseau interne et n'est pas exposée au web (selon comment vous créez votre réseau bien sûr).

## réplication de stockage 

Maintenant, comme nous avons fini les préparations, nous devons configurer notre réplication de stockage pour /mnt/replicated et /mnt/distreplic (pas /mnt/mysql-db, parce que mariadb utilisera un autre mécanisme pour répliquer ses données).

Cette fois nous utiliserons GlusterFS, simple et efficace, il répondra à nos trois besoins :
- nous avons besoin de la possibilité de répliquer sur tous les serveurs, ou juste avec deux copies sur un stockage HA
- il doit être assez rapide pour suivre notre service web (cela dépend principalement du matériel, mais la vitesse de la couche logicielle est importante aussi).
- Nous voulons configurer des quotas sur les dossiers qui peuvent être utilisés par notre conteneur docker pour limiter l'utilisation du disque.

Ok pour Gluster ! Il y a d'autres solutions bien sûr (comme Ceph node etc), et vous devriez étudier celles-ci selon les besoins de votre projet, ou si vous devez employer un NAS avec partage nfs etc... 

Mais cette fois, c'est la gloire pour Gluster !

- 1-1 : Démarrer l'installation 

D'abord allez au deuxième serveur (cluster-2) connectez-vous en root et clonez à nouveau (si ce n'est pas déjà fait) ce dépôt et lancez le premier script :

```
git clone -b Swarm https://github.com/INRAI-helPHP/helPHP-env-install && \
cd helPHP-env-install && \
bash 1-1-gluster-B.sh
```
- 1-2 : Lancer la réplication 

Deuxièmement, connectez-vous en root et cd dans helphp-env-install sur le premier serveur et :

`bash 1-2-gluster-A.sh`

A cette étape il se peut que gluster s'initialise mal sur certaines versions de debian.
Dans ce cas là, il faut relancer gluster.
Sur tous les serveurs faîtes :
```
sudo systemctl stop glusterd
sudo rm -rf /var/lib/glusterd
sudo systemctl start glusterd
```
puis relancer le script `bash 1-2-gluster-A.sh`

- 1-3 : Fixer les nouveaux volumes dans fstab 

C'est déjà fait sur le premier serveur sur le script précédent, mais comme la réplication est lancée, nous devons fixer les volumes sur le second.
donc sur le deuxième serveur cd dans helphp-env-install et :

`./1-3-gluster-B.sh`

si vous mettez quelque chose dans /mnt/replicated ou /mnt/distreplic vous devriez le trouver sur les deux machines.

Notez qu'à ce moment, comme nous avons seulement deux serveurs, la réplique est définie à 2 sur les deux volumes, si vous avez un plus grand nombre de serveurs, pour /mnt/replicated, le nombre de réplique doit être le même pour répliquer les fichiers de blocs sur tous les serveurs.
Mais pour /mnt/distreplic vous avez juste besoin de le laisser à 2 (deux copies suffisent). 
Pourquoi cette différence ?

Quand les services démarrent, les services ont besoin de leurs fichiers de config etc, donc nous devons en disposer sur tous les serveurs, et comme ça même s'il n'y a qu'un serveur laissé il devrait être capable de lancer tous les services.
Et la vitesse d'accès est importante donc ces fichiers doivent être locaux partout.

/mnt/distreplic est pour les données utilisateur/persistantes, elles peuvent être sur un NFS ou tout stockage externe, ou sur un stockage distribué, leur vitesse d'accès est moins importante, donc nous pouvons les récupérer via réseau, et avec une distribution correcte des blocs répliqués, il y a très peu de chance de perte de données.

Note : Après un reboot, si vous tapez `df` parfois vos volumes gluster n'apparaissent pas, et il suffit de taper `cd /mnt/replicated` pour les faire apparaître, donc un petit "cron job" au boot est parfois nécessaire selon votre config/distro.

## Docker et swarm

Il est maintenant temps de rendre le swarm ALIIIVVEEEE (HHUUhuhuh désolé...)!

- 2-0 l'utilisateur docker :

Sur les deux serveurs, en root, dans helph-env-install, lancez 

`./2-0-docker-user.sh` et répondez les mêmes réponses sur les deux. 

Dès que notre utilisateur docker est créé, nous continuerons avec lui, donc `su docker_username` 

- 3-0 l'installation swarm :

Sur le premier serveur, avec votre utilisateur docker lancez `./3-0-swarm-A.sh` et indiquez l'IP interne de ce serveur (ou l'ip unique que vous avez si vous avez seulement une carte réseau)

Votre premier serveur deviendra le premier gestionnaire swarm, et dans le dossier /mnt/replicated, vous trouverez un nouveau dossier "swarm-tokens" avec les commandes pour que de nouveaux serveurs rejoigne le swarm en tant que "worker" ou "manager".

C'est un gestionnaire swarm mais aussi un nœud dans le swarm, donc il hébergera aussi des services, et le script lui donne un premier label : "mariadb-master" , ce label indiquera sur quel serveur sera hébergé et lancé mariadb en tant que master et ses données SQL. Bien sûr, à l'étape suivante le deuxième serveur sera étiqueté comme "slave". 

En cas de crash, helPHP s'appuiera sur le serveur survivant (vous pouvez forcer le serveur SQL survivant comme serveur principal dans votre fichier d'instance config/db.php si l'automatisation n'est pas suffisante).

Donc quand vous réparerez votre cluster, n'oubliez pas d'ajouter/mettre à jour/changer les labels selon la situation.

- 3-1 rejoindre le swarm :

Sur le deuxième serveur, en tant qu'utilisateur docker, lancez `3-1-swarm-B.sh` .

Il ira chercher le token dans /mnt/replicated/swarm-tokens (merci gluster !), fera rejoindre le deuxième serveur au swarm aussi en tant que gestionnaire (quand il y a très peu de serveurs, séparer gestionnaire et workers n'est pas vraiment nécessaire), et sera étiqueté comme mariadb-slave !

Nous sommes maintenant prêts à lancer nos services, mais quelques dernières préparations sont nécessaires.

## Préparer le lancement

- 4-0 quelques dossiers :

toujours en tant qu'utilisateur docker dans helphp-env-install dans le premier serveur, lancez juste :

`./4-0-preparation.sh`

sur le deuxième serveur, toujours en tant qu'utilisateur docker faites :

```
mkdir -p /mnt/mysql-db/mysql/maria-slave \
/mnt/mysql-db/logs/maria-slave

```

- 5-0 notre conteneur HelPHP : 

toujours en tant qu'utilisateur docker dans helphp-env-install sur n'importe quel serveur, lancez juste :

`./5-0-add-container.sh` et indiquez un nom pour le conteneur.

Et c'est ça ! un fichier mainstack.yml est maintenant dans /mnt/replicated et devrait être prêt à lancer

## lancer

Avant de lancer, jetez un œil à /mnt/replicated/mainstack.yml :

C'est votre pile pour le swarm, décrivant chaque service, conditions, et route gérées par le proxy inverse traefik.

Pour le premier démarrage, il ne s'appuiera pas sur un domaine ni sur https. 
La config https est commentée et vous devriez passer de "web" à "websecure" dès que vous avez un domaine. 

les règles pour le conteneur helPHP et phpmyadmin sont simples, ils répondront dès que nous demandons /helphp et /pma après la première ou deuxième ip externe du serveur ou domaine.

La pile n'est pas totalement finie et parfaite, vous devriez acheter un domaine, ou créer un dns local avec un faux domaine pour faire quelques redirections dns "round robin" vers les deux ips, et ajouter le support https etc. 

Quoi qu'il en soit, nous pouvons déjà le tester comme cela : 

`docker stack deploy -c /mnt/replicated/mainstack.yml hphp`

`docker service ls` montrera quand tout est prêt et lancé (la première fois il a besoin de télécharger les images des services) et quand prêt, si vous tapez une de vos ips externes de serveur (elle devrait répondre sur les deux) vous devriez obtenir le script d'installation HelPHP . Amusez vous bien avec la créature :)

Veuillez noter que si vous ne pouvez pas vous connecter/ouvrir une session avec votre conteneur, en général c'est un problème avec redis, donc vérifiez ses logs (docker service logs hphp_redis).

Notez encore : Si vous avez des problèmes de permission sur le repo helPHP ou votre instance, vous pouvez utiliser /mnt/replicated/helphp/utils/change-rights.sh .

Notez encore que si vous utilisez des VM très petites, vous ne devriez pas lancer libretranslate.

Maintenant vous devriez vérifier la documentation sur [helphp.org](helphp.org/install/helphp) à propos de la configuration d'installation HelPHP, mais au moins , définissez dans config/main.php la constante "CLUSTER" à "true", si vous l'avez manquée pendant l'installation.