#create directory tree
#comment this if u dont use volume mounts
mkdir -p volumes/node{1..6}-data/var-lib-redis

#build redis cluster image
build . --tag redis-cluster:4.0.0
