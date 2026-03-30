<img src="logo-border.svg" width="55%" />

# Installation LAMP helphp

Cette branche décrit comment installer HelPHP avec une pile LAMP classique.
Nous allons installer les libs HelPHP et une instance HelPHP, mais vous pouvez bien sûr exécuter plusieurs instances (tout dépend de votre configuration Apache.).
Notez que vous pouvez aussi utiliser les permissions utilisateur Linux pour diviser les instances et interdire les interactions entre comptes, dans ce cas faites attention à la constante "APACHE_USER" dans votre fichier de configuration principal.

## Le serveur

Nous choisissons un debian 13 pour cette installation, presque toute la famille debian (ubuntu, mint etc), peut utiliser directement ce guide sans aucune modification.
Pour d'autres distros, vous devrez adapter les différents scripts sh (rpm au lieu de deb apt etc). mais la logique est la même. 
(si vous voulez contribuer et pousser une installation adaptée pour votre distro favorite, n'hésitez pas à laisser une `suggestion` dans le tableau des issues)

## Allons installer les trucs :
- 1 vous devriez avoir git installé et être connecté en tant que super utilisateur.

```
sudo su
apt install git
```

- 2 clonez cette branche : 
```
git clone -b LAMP https://github.com/INRAI-helPHP/helPHP-env-install`
```
- 3 lancez le premier script d'installation pour obtenir Apache et PHP-FPM 8.4 : 
```
cd helPHP-env-install
chmod 777 *-*.sh
./1-install-apache-php8-4.sh
```

- 4 test : si vous tapez l'ip de votre serveur dans la barre d'adresse de votre navigateur, vous devriez obtenir la page par défaut d'Apache.

- 5 Avons-nous besoin d'un serveur Mysql sur le même serveur ? 
Si oui, pour installer MariaDB (un excellent serveur mysql), retournez dans helphp-env-install Choisissez un mot de passe correct pour votre utilisateur root/admin mysql et exécutez :

`./2-install-mariadb.sh YOUR_PASSWORD` 

- 6 Avez-vous besoin de PhpMyAdmin ?
toujours dans helphp-env-install lancez :

`./3-install-pma.sh` 

pendant l'installation, sélectionnez "apache" comme serveur web et confirmez que vous voulez configurer phpmyadmin avec dbconfig-common. Vous pouvez aussi sélectionner un mot de passe pour la db phpmyadmin ou le laisser aléatoire.

Après cela, dans la barre d'adresse de votre navigateur, vous pouvez taper l'ip de votre serveur suivi de "/phpmyadmin" 
et accéder à phpmyadmin et inspecter votre serveur Mariadb avec l'utilisateur root et votre mot de passe spécifié à l'étape 5.

- 7 Avez-vous besoin de ffmpeg pour l'encodage vidéo ?

`./4-install-ffmpeg.sh`

- 8 Avez-vous besoin de Redis (pour les sessions rapides et le suivi des processus mutualisés ?).

`./5-install-redis.sh`

- 9 Clonez HelPHP et son instance : 
allez dans le dossier où vous voulez installer les libs HelPHP et clonez-les là :
`git clone https://github.com/INRAI-helPHP/helPHP`

puis nous clonerons l'instance dans le répertoire servi par défaut d'apache :
```
cd /var/www/html
rm *
git clone https://github.com/INRAI-helPHP/helPHP-instance /var/www/html
chown -R www-data:www-data *
cd ..
mkdir data
chown www-data:www-data data
```
le dossier /var/www/data sera utilisé pour stocker les données manipulées par le système de fichiers helPHP .
Prenez soin de vérifier votre configuration d'instance puis dans la barre d'adresse de votre navigateur tapez l'ip de votre serveur + '/installscript.php' et vous devriez obtenir l'installateur final HelPHP.

si vous voulez une autotranslation pour l'UI et le contenu, vous devriez vérifier la version [Composer](https://github.com/INRAI-helPHP/helPHP-env-install/tree/Composer), ou installer libretranslate comme un conteneur docker mais pas directement sur la même instance de serveur car c'est vraiment consommateur de ressources.