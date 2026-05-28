<img src="logo-border.svg" width="55%" />

# Installation en une ligne ... Sur quoi ?

Si vous avez un serveur ou une VM exécutant un Linux récent comme Debian, Ubuntu ou Mint prêt à l'emploi sans rien d'installé, connectez-vous en tant que root/sudo et copiez-collez cette commande :

```
apt install -y git && \
git clone -b Compose https://github.com/INRAI-helPHP/helPHP-env-install && \
bash helPHP-env-install/one_line_install.sh
```

Le script demandera un nom d'utilisateur et un mot de passe pour créer un utilisateur dédié à docker et lancer les services HelPHP, un nom pour votre conteneur HelPHP, et enfin le mot de passe root pour votre serveur SQL MariaDB.

Quand terminé, vous trouverez dans /mnt/replicated un fichier nommé launch.sh .

Connectez-vous en tant que votre nouvel utilisateur Docker (su username) et lancez le script : /mnt/replicated/launch.sh 

puis dans votre navigateur, tapez http://+l'adresse ip de votre serveur ou VM et vous devriez obtenir la page d'installation HelPHP.

Amusez vous bien ;)

Vous pouvez éditer votre instance HelPHP dans /mnt/distreplic/custhome/NAME_OF_YOUR_CONTAINER/default
Vous pouvez suivre les logs dans /mnt/distreplic/logs/NAME_OF_YOUR_CONTAINER/...
et votre dépôt de libs HelPHP est dans /mnt/replicated/helphp

intéressé par ce qui a été fait sur votre serveur ? Veuillez vérifier la branche [Compose](https://github.com/INRAI-helPHP/helPHP-env-install/tree/Compose).