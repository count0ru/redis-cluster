FROM debian:jessie-slim

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r redis && useradd -r -g redis redis

# grab gosu for easy step-down from root
# https://github.com/tianon/gosu/releases
ENV GOSU_VERSION 1.10
RUN set -ex; \
	\
	fetchDeps='ca-certificates wget'; \
	apt-get update; \
	apt-get install -y --no-install-recommends $fetchDeps; \
	rm -rf /var/lib/apt/lists/*; \
	\
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
	wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
	gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
	rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc; \
	chmod +x /usr/local/bin/gosu; \
	gosu nobody true; \
	\
	apt-get purge -y --auto-remove $fetchDeps

ENV REDIS_VERSION 4.0.0
ENV REDIS_DOWNLOAD_URL http://download.redis.io/releases/redis-4.0.0.tar.gz
ENV REDIS_DOWNLOAD_SHA d539ae309295721d5c3ed7298939645b6f86ab5d25fdf2a0352ab575c159df2d

# for redis-sentinel see: http://redis.io/topics/sentinel
RUN set -ex; \
	\
	buildDeps=' \
		wget \
		gcc \
		libc6-dev \
		make \
	'; \
	apt-get update; \
	apt-get install -y $buildDeps --no-install-recommends; \
	rm -rf /var/lib/apt/lists/*; \
	\
	wget -O redis.tar.gz "$REDIS_DOWNLOAD_URL"; \
	echo "$REDIS_DOWNLOAD_SHA *redis.tar.gz" | sha256sum -c -; \
	mkdir -p /usr/src/redis; \
	tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1; \
	rm redis.tar.gz; \
	\
# disable Redis protected mode [1] as it is unnecessary in context of Docker
# (ports are not automatically exposed when running inside Docker, but rather explicitly by specifying -p / -P)
# [1]: https://github.com/antirez/redis/commit/edd4d555df57dc84265fdfb4ef59a4678832f6da
	grep -q '^#define CONFIG_DEFAULT_PROTECTED_MODE 1$' /usr/src/redis/src/server.h; \
	sed -ri 's!^(#define CONFIG_DEFAULT_PROTECTED_MODE) 1$!\1 0!' /usr/src/redis/src/server.h; \
	grep -q '^#define CONFIG_DEFAULT_PROTECTED_MODE 0$' /usr/src/redis/src/server.h; \
# for future reference, we modify this directly in the source instead of just supplying a default configuration flag because apparently "if you specify any argument to redis-server, [it assumes] you are going to specify everything"
# see also https://github.com/docker-library/redis/issues/4#issuecomment-50780840
# (more exactly, this makes sure the default behavior of "save on SIGTERM" stays functional by default)
	\
	make -C /usr/src/redis -j "$(nproc)"; \
	make -C /usr/src/redis install; \
	\
	rm -r /usr/src/redis; \
	\
	apt-get purge -y --auto-remove $buildDeps

#
# ReJSON JSON storing and parsing support
#
ENV REJSON_COMMIT be53adb0f46972f50d2a55486d46256644dfa2e2
ENV REJSON_DOWNLOAD_URL "https://github.com/RedisLabsModules/rejson/archive/$REJSON_COMMIT.tar.gz"
ENV REJSON_DOWNLOAD_SHA 8d5e725800a46ce31bbe10ebb308bc29bf0f8f8fa74fafa0e1409048b48c6e92

RUN set -ex; \
	\
	buildDeps=' \
		build-essential \
		wget \
		ca-certificates \
	'; \
	apt-get update; \
	apt-get install -y $buildDeps --no-install-recommends; \
	rm -rf /var/lib/apt/lists/*; \
	\
	mkdir -p /usr/src/rejson; \
	wget -O rejson.tar.gz "$REJSON_DOWNLOAD_URL"; \
	echo "$REJSON_DOWNLOAD_SHA *rejson.tar.gz" | sha256sum -c -; \
	mkdir -p /usr/src/rejson; \
	tar -xzf rejson.tar.gz -C /usr/src/rejson --strip-components=1; \
	rm rejson.tar.gz; \
	\
	make -C /usr/src/rejson -j "$(nproc)"; \
	\
	mkdir -p /usr/local/lib/rejson; \
	cp /usr/src/rejson/src/rejson.so /usr/local/lib/rejson/rejson.so; \
	\
	rm -r /usr/src/rejson; \
	\
	apt-get purge -y --auto-remove $buildDeps

RUN mkdir /data && chown redis:redis /data
VOLUME /data
WORKDIR /data

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
RUN mkdir /var/lib/redis
RUN chown redis:redis /var/lib/redis
RUN mkdir /etc/redis
COPY redis.conf /etc/redis/redis.conf
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 6379
CMD ["redis-server"]
