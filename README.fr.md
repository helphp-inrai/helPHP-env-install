<img src="logo-border.svg" width="55%" />

# helphp-env-install
Ce dépôt fait partie du projet [helPHP](https://helphp.org), et a la même licence et règles de contribution que le [dépôt principal de helPHP](https://github.com/INRAI-helPHP/helPHP).


## Objectif

Si vous avez déjà un environnement PHP en cours d'exécution, vous pouvez simplement git pull [helPHP](https://github.com/INRAI-helPHP/helPHP) et sa [instance](https://github.com/INRAI-helPHP/helPHP-instance) par défaut quelque part et lancer son installation.
Mais la plupart du temps, quand vous commencez un nouveau projet, vous devez aussi prendre le contrôle total de l'environnement. Pour des raisons de performance et de sécurité en général.
Pour vous aider, nous avons fait quelques scripts pour installer l'environnement rapidement, prendre soin de certains problèmes de sécurité, comme exécuter docker rootless etc..

## Faire fonctionner HelPHP !

Pour vous aider à exécuter HelPHP, vous avez besoin de certains logiciels d'environnement : PHP, un serveur httpd, peut-être un serveur SQL, peut-être un noSql etc...
Les choix faits pour l'environnement impactent sur les performances et la sécurité.
Par exemple, sous Windows avec docker ou composer, vous aurez de mauvaises performances sur certaines opérations de système de fichiers.

Mais vous devez aussi penser à la scalabilité de votre App !

Donc, voici différents exemples d'installation qui sont progressifs en complexité, vous devriez lire chaque readme, sur chaque branche dans l'ordre ci-dessous pour comprendre certains choix sous-jacents faits dans les libs HelPHP plus tard.

Vous trouverez aussi diverses manières d'installer parce que nous ne pouvons pas prétendre couvrir toutes les techno de déploiement VM/cloud/cluster/serveur mais, au final, nous pouvons montrer tous les grands principes pour vous aider à adapter l'installation à votre propre environnement, et quelques scripts pour vous aider.

Veuillez sélectionner la branche correspondant à votre situation matériel / cloud et suivre son readme.

## Sélectionner la branche/version d'installation :
- [One-line-install](https://github.com/INRAI-helPHP/helPHP-env-install/tree/one_line_install) : Pas de temps, ou besoin d'exécuter HelPHP immédiatement ? Cette branche est pour vous !
- [LAMP](https://github.com/INRAI-helPHP/helPHP-env-install/tree/LAMP) : l'installation classique Linux / Apache / MySQL / PHP ... directement sur un serveur vide (famille debian)
- [Docker](https://github.com/INRAI-helPHP/helPHP-env-install/tree/Docker) : obtenir ou construire un conteneur docker pour HelPHP
- [Composer solo](https://github.com/INRAI-helPHP/helPHP-env-install/tree/Composer) : installer avec docker composer avec un seul serveur mysql
- [Composer avec maître esclave (et optionnellement utilisateur centralisé) serveur mysql](https://github.com/INRAI-helPHP/helPHP-env-install/tree/Composer-multi-mysql)
- [Docker swarm](https://github.com/INRAI-helPHP/helPHP-env-install/tree/Swarm) version avec HA sur deux serveurs

## Après l'installation ou votre environnement :

Maintenant vous devez installer helPHP lui-même, alors faisons-le : [documentation d'installation helPHP](https://helphp.org/install/helphp)

## Faites un don pour nous aider 
 
Sur la page d'accueil de [helphp.org](https://www.helphp.org), vous trouverez un bouton de don. 
Avec cela, vous pouvez faire un don unique ou récurrent pour soutenir notre travail.
Bien sûr, comme toute équipe, nous avons besoin d'argent pour payer les différents services (serveurs/domaines/électricité) et quand il y en a assez, nous pouvons embaucher de l'aide pour accélérer sur le WIP actuel. 
Donc, si vous voulez nous aider ou juste nous offrir un petit café, merci d'avance :)