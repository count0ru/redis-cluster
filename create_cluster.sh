#install redis tools (for deb based linux)
apt-get update && apt-get install ruby wget redis-tools -y

#download and install redis cluster tool
wget http://download.redis.io/redis-stable/src/redis-trib.rb
chmod +x redis-trib.rb
gem install redis

./redis-trib.rb create --replicas 1 $(echo $(for i in {1..6}; do docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' rediscluster_node-$i\_1; done  | sed ':a;N;$!ba;s/\n/:6379 /g'):6379)

echo run
echo redis-cli -c -h <ANY NODE IP> CLUSTER INFO
echo for info
