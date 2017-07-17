#!/bin/bash

#install redis tools (for deb based linux)
apt-get update && apt-get install ruby wget redis-tools -y

#download and install redis cluster tool
wget http://download.redis.io/redis-stable/src/redis-trib.rb -O ./redis-trib.rb
chmod +x redis-trib.rb
gem install redis

./redis-trib.rb create --replicas 1 $(echo $(for i in {1..6}; do docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' rediscluster_node-$i\_1; done | sed ':a;N;$!ba;s/\n/:6379 /g'):6379)

echo -e "\n \t \e[32m \033[1m ALL DONE! \033[0m \n"
echo 'Please, run:'
echo '`redis-cli -c -h <ANY YOUR DOCKER CLUSTER IP> CLUSTER INFO`'
echo 'to read information about the assembled cluster'