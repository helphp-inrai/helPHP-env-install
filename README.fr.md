<img src="logo-border.svg" width="55%" />

# Introduction

Nous avons deux façons d'installer tout dans cette branche :

- 1 : vous êtes pressé ? Pas de temps de voir les détails ? 

Copiez-collez simplement cette ligne dans votre terminal serveur ou VM (fonctionne avec les distros Debian/Ubuntu/Mint récentes) :

```
apt install -y git && \
git clone -b Composer https://github.com/INRAI-helPHP/helPHP-env-install && \
bash helPHP-env-install/one_line_install.sh
```
- 2 : vous avez 20 minutes ? 

Alors continuez à lire :

Avant de commencer avec composer, vous devez installer docker et créer quelques dossiers etc...

Veuillez appliquez les scripts en lisant le readme de cette branche (si ce n'est pas déjà fait) : [Docker](https://github.com/INRAI-helPHP/helPHP-env-install/tree/Docker) mais ne lancez pas le conteneur.

Nous avons dans la branche "composer" les mêmes fichiers et scripts que la branche "Docker" précédente car c'est la même base.
Donc après avoir utilisé le script 2-add-container.sh, nous continuerons avec composer ...

## Pourquoi composer ?

Vous êtes développeur ? ou vous avez juste un serveur sur lequel vous commencez à avoir plusieurs services et vous voulez contrôler leurs ressources ? Composer est un bon choix pour garder les choses simples avec de bonnes performances...

Comme il est déjà installé avec docker, nous pouvons directement "composer" une "pile" de services, et la lancer/l'arrêter en une commande.

## Pour Docker desktop sous Windows :
Vous pouvez utiliser la pile composer avec Docker desktop sous Windows, mais pour éviter les problèmes, vous devriez créer tous les dossiers dans un seul dossier, et à l'intérieur mettre votre fichier yaml. Comme cela vous pourrez utiliser des chemins relatifs (car écrire des chemins absolus peut être difficile sous Windows).

Certaines opérations système sont vraiment lentes sous Windows, comme calculer l'espace disque libre, ou l'espace occupé pour un dossier etc... Nous recommandons de l'utiliser seulement pour le dev local.

## Continuons...
Dans la branche précédente pour docker, nous avons juste lancé un conteneur d'exécution d'instance HelPHP dédié (H.C pour le raccourcir), mais seul il manquera une connexion à un serveur MySQL et si nous voulons des performances et de la scalabilité, un server Redis. et probablement nous aurons besoin d'un autre H.C pour des projets spéciaux etc... 

Et aussi, cette fois, nous voulons peut-être ajouter Libretranslate, et PhpMyadmin, pourquoi pas ?

- 1 git clone cette branche quelque part :
`git clone -b Composer https://github.com/INRAI-helPHP/helPHP-env-install`

vous trouverez à l'intérieur les fichiers précédents de la branche Docker et quelques nouveaux fichiers utiles...

- 2 ajouter quelques dossiers :

Donc nous aurons besoin d'ajouter quelques dossiers pour tous ces services :

rappelez-vous, dans /mnt/ nous avons replicated , myslq-db et distreplic (si vous avez déjà utilisé le script n°1).

Si ce n'est pas déjà fait ajoutez HelPHP :
```
mkdir /mnt/replicated/helphp
git clone https://github.com/INRAI-helPHP/helPHP.git /mnt/replicated/helphp
```

nous allons créer un serveur MySQL nommé "mymaria" et basé sur une version classique de mariaDB .

donc sous votre utilisateur docker :

```
cd /mnt/
mkdir replicated/redis \
replicated/pma \
replicated/mymaria \
mysql-db/mymaria 
```

revenez dans le dossier helphp-env-install

```
cp confs/mysql/my-init.cnf /mnt/replicated/mymaria/ &&\
cp confs/phpmyadmin/config.inc.php /mnt/replicated/pma/ &&\
cp compose.yaml /mnt/replicated/ &&\
cp -r confs/libretranslate /mnt/replicated/ &&\
chmod -R 777 /mnt/replicated/libretranslate &&\
cp compose.yaml /mnt/replicated/
```

- 3 Éditez compose.yaml

Avec nano ou n'importe quel éditeur de texte, éditez /mnt/replicated/compose.yaml.

Oui nous avons déjà fait le travail ! Et vous avez très peu de choses à faire :
ls
une pile composer est divisée en services, le premier correspond exactement au docker run que nous avons fait dans la branche "Docker", avec les mêmes volumes, le même port, donc vous devez remplacer 
"YOUR.H.C.NAME" par le nom que vous avez donné quand vous avez lancé le script 2-add-container.sh.

Le deuxième service est votre premier serveur mysql, et il aura besoin d'un mot de passe root, donc remplacez "YOURPASSWORD" par un choisi !

- 4 quelques infos sur cette pile :

vous verrez que nous montons my-init.cnf dans mariadb, vous permettant d'ajuster ses paramètres si nécessaire.

même chose pour le premier service : phpmyadmin, avec config.inc.php.

Important : nous donnons le numéro de port 8001 à phpmyadmin, donc si vous tapez votre ip serveur + :8001 vous obtiendrez phpmyadmin (pas de numéro de port pour l'instance helphp, car elle est redirigée vers 80).

Le quatrième service est redis, qui sauvegardera un petit fichier nosql dans replicated/redis pour redémarrer en cas de crash avec des sessions ou processus encore vivants.

Le cinquième est libretranslate, il commencera à télécharger immédiatement ses paquets de langues, donc il ne sera pas opérationnel jusqu'à ce que ce soit fini. N'oubliez pas de générer une nouvelle clé API (jetez un œil à leur [documentation](https://docs.libretranslate.com/guides/manage_api_keys/) ) et ajoutez-la dans config/main.php dans votre instance helphp. (toujours dans ce fichier de config, l'url pour libretranslate devrait être http://libretranslate:5000/)

## Lancez-le !
Toujours en tant que votre utilisateur docker, allez dans /mnt/replicated où se trouve votre fichier compose.yaml et lancez :
`docker compose up --detach`
Et profitez !

Peut-être aurez-vous besoin de configurer les droits utilisateur sur les fichiers d'instance helphp si c'est votre première installation : 
`docker exec -ti name_or_id_of_container chown -R www-data:users /home/default`

allez dans votre navigateur et tapez l'adresse ip de votre serveur (localhost ou 127.0.0.1 si c'est votre ordinateur) pour commencer l'installation de l'instance helphp ou + ":8001" pour aller à phpmyadmin.


`docker compose down` pour tuer la pile.

Et maintenant nous commençons à avoir quelque chose que nous pouvons appeler "Une pile simple" mais avec assez de division de services et de petites choses faites (comme les fichiers de config externes en vert dans le schéma ci-dessous) pour l'évolution ... 

![composer.png](composer.png)

Vous devrez toujours penser à comment vous gérerez votre cpu, stockage (et type de stockage!), bande passante et ressource mémoire, et comment votre projet grandira ! 

Donc la scalabilité, mais aussi la haute disponibilité, doivent être réflechies dés le début du projet.

De ce point de vue, la première chose à étudier c'est le stockage de longue durée des données en base de données (les données volatiles, comme les sessions, le suivi des processus peuvent être stockées dans mysql, mais il est mieux d'utiliser un noSQL rapide comme redis pour cela, car ces données ne sont pas essentielles). 
Les données de longue durée sont souvent stockées dans un DB de type SQL et ce type de serveur offre le plus souvent des mécanismes de réplication cluster ou maître/esclave. 

heureusement, avec composer nous pouvons facilement expérimenter ces mécanismes de réplication. 

Jetez un œil à la branche [Composer multi MySQL](https://github.com/INRAI-helPHP/helPHP-env-install/tree/Composer-multi-mysql).