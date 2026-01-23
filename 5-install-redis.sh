#!/bin/bash
apt install -y redis redis-server redis-tools
echo "redis installed, testing it"
apt-cache policy redis
systemctl enable redis-server --now
echo "redis seems ok, in your config think about indicating 127.0.0.1 as redis url and 6379 as port number"