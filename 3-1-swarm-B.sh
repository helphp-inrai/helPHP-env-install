#!/bin/bash

token=`echo "$a" | sed -n '3p' < /mnt/replicated/swarm-tokens/manager.txt`

eval $token

docker node update --label-add mariadb-slave=true $HOSTNAME

echo "welcome in the SWAAAARRRMMM ! type 'docker node list' to check it"