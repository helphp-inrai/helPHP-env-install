<img src="logo-border.svg" width="55%" />

# helphp-env-install
This repository is a part of the [helPHP](https://helphp.org) project, and got the same licence and contributing rules as the [main repository of helPHP](https://github.com/INRAI-helPHP/helPHP).


## Purpose

if you have already a php environnement running, you can simply git pull [helPHP](https://github.com/INRAI-helPHP/helPHP) and it's default [instance](https://github.com/INRAI-helPHP/helPHP-instance) somewhere and launch its installation.
But most of the time, when you start a new project, you need also to take full control of the environnement. For performance and security reason in general.
To help you we made some scripts to install the environnement quickly, take care of some security issue, like running docker rootless etc..

## Getting HelPHP running !

To help you run HelPHP, you need some environnement software : PHP, an httpd server, perhaps a SQL server, perhaps a noSql one etc...
the choices made for the environnement impact on the performance and the security.
For exemple, under Windows with docker or composer you'll have poor performances on some filesystem operation.

But also you must think about the scalability of your App !

So, here comes different installation exemples that are progressive in complexity, you should read each readme, on each branch in the order bellow to understand some underlying choice made in HelPHP libs later.

You'll find also various manor to install because we can't pretend covering all VM/cloud/cluster/server deploy techno but, at last, we can show all big principles to help you adapt the installation to your own environnement, and some scripts to help you.

PLease select the branch corresponding to your hardware / cloud situation and follow its readme.

## Select branch/installation version :
- [One-line-install](https://github.com/INRAI-helPHP/helPHP-env-install/tree/one_line_install) : No time, or need to run immediatly HelPHP? This branch is for you!
- [LAMP](https://github.com/INRAI-helPHP/helPHP-env-install/tree/LAMP) : the classic Linux / Apache / MySQL / PHP install ... directly on an empty server (debian family)
- [Docker](https://github.com/INRAI-helPHP/helPHP-env-install/tree/Docker) : get or build a docker container for HelPHP
- [Composer solo](https://github.com/INRAI-helPHP/helPHP-env-install/tree/Composer) : install with docker composer with a single mysql server
- [Composer with master slave (and optionnaly centralized user ) mysql server](https://github.com/INRAI-helPHP/helPHP-env-install/tree/Composer-multi-mysql)
- [Docker swarm](https://github.com/INRAI-helPHP/helPHP-env-install/tree/Swarm) version with HA on two servers

## After installation or your environment :

Now you need to install helPHP itself, so let's do it : [helPHP installation documentation](https://helphp.org/install/helphp)

## Donate to help us 
 
On [helphp.org](https://www.helphp.org) homepage, you'll find a donate button. 
With it, you can make a oneshot or recurring donation to support our work.
Of course, like any team, we need some money to pay the different services (servers/domains/electricity) and when their is enough money, we can hire some help to speed up on the current WIP. 
So if you want to help up of just offer to us a little coffee, thanks in advance :)
