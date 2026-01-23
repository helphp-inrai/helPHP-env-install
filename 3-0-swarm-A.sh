#!/bin/bash

read -p "Please indicate your swarm manager ip : " ip

mkdir /mnt/replicated/swarm-tokens
docker swarm init --advertise-addr ${ip} > /mnt/replicated/swarm-tokens/worker.txt

docker swarm join-token manager > /mnt/replicated/swarm-tokens/manager.txt

docker network create --driver=overlay traefik
docker network create --driver=overlay webgateway

docker node update --label-add mariadb-master=true $HOSTNAME

