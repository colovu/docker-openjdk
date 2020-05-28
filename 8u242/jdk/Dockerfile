FROM colovu/ubuntu:18.04

ENV JAVA_VERSION=8u242 \
	JAVA_URL_VERSION=8u242b08 \
	LANG=C.UTF-8 \
	JAVA_HOME=/usr/local/openjdk-8

ENV JDK_HOME="${JAVA_HOME}" \
	CLASSPATH="${JAVA_HOME}/lib:${CLASSPATH}" \
	PATH="/usr/local/openjdk-8/bin:${PATH}"

LABEL \
	"Version"="v${JAVA_VERSION}" \
	"Description"="Docker images for openJDK jdk-${JAVA_VERSION} based on Ubuntu 18.04." \
	"Dockerfile"="https://github.com/colovu/docker-openjdk" \
	"Vendor"="Endial Fang (endial@126.com)"

RUN set -eux; \
# 设置程序使用静默安装，而非交互模式；类似tzdata等程序需要使用静默安装
	export DEBIAN_FRONTEND=noninteractive; \
	\
	mkdir -p ${JAVA_HOME}; \
	\
	apt update; \
	apt-get install -y --no-install-recommends ca-certificates p11-kit; \
	\
# 更新源，并安装临时使用的软件包（使用完后可删除）
	fetchDeps=" \
		bzip2 \
		unzip \
		xz-utils \
# 签名验证工具
		dirmngr \
		gnupg \
		fontconfig libfreetype6 \
		curl \
		tzdata \
	"; \
	savedAptMark="$(apt-mark showmanual)"; \
	apt install -y --no-install-recommends ${fetchDeps}; \
	\
	JAVA_BASE_URL="https://github.com/AdoptOpenJDK/openjdk8-upstream-binaries/releases/download/jdk8u242-b08/OpenJDK8U-jdk_"; \
	curl --progress-bar -L -o openjdk.tgz.asc "${JAVA_BASE_URL}x64_linux_${JAVA_URL_VERSION}.tar.gz.sign"; \
	curl --progress-bar -L -o openjdk.tgz "${JAVA_BASE_URL}x64_linux_${JAVA_URL_VERSION}.tar.gz"; \
	\
# 下载方式安装软件，使用GPG签名方式验证软件
	export GPG_KEYS="0xCA5F11C6CE22644D42C6AC4492EF8D39DC13168F 0xEAC843EBD3EFDB98CC772FADA5CD6035332FA671"; \
	export GNUPGHOME="$(mktemp -d)"; \
	for key in ${GPG_KEYS}; do \
		gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "${key}"|| \
		gpg --batch --keyserver pgp.mit.edu --recv-keys "${key}" || \
		gpg --batch --keyserver keys.gnupg.net --recv-keys "${key}" || \
		gpg --batch --keyserver keyserver.pgp.com --recv-keys "${key}"; \
	done; \
	gpg --batch --verify openjdk.tgz.asc openjdk.tgz; \
	command -v gpgconf > /dev/null && gpgconf --kill all; \
	rm -rf "$GNUPGHOME"; \
	\
	tar --extract --file openjdk.tgz --strip-components 1 --no-same-owner --directory "$JAVA_HOME"; \
	rm openjdk.tgz*; \
	\
# 为中国区使用重新配置tzdata信息
	ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime; \
	dpkg-reconfigure -f noninteractive tzdata; \
	\
# update "cacerts" bundle to use Debian's CA certificates (and make sure it stays up-to-date with changes to Debian's store)
	{ \
		echo '#!/usr/bin/env bash'; \
		echo 'set -Eeuo pipefail'; \
		echo 'if ! [ -d "$JAVA_HOME" ]; then echo >&2 "error: missing JAVA_HOME environment variable"; exit 1; fi'; \
# 8-jdk uses "$JAVA_HOME/jre/lib/security/cacerts" and 8-jre and 11+ uses "$JAVA_HOME/lib/security/cacerts" directly (no "jre" directory)
		echo 'cacertsFile=; for f in "$JAVA_HOME/lib/security/cacerts" "$JAVA_HOME/jre/lib/security/cacerts"; do if [ -e "$f" ]; then cacertsFile="$f"; break; fi; done'; \
		echo 'if [ -z "$cacertsFile" ] || ! [ -f "$cacertsFile" ]; then echo >&2 "error: failed to find cacerts file in $JAVA_HOME"; exit 1; fi'; \
		echo 'trust extract --overwrite --format=java-cacerts --filter=ca-anchors --purpose=server-auth "$cacertsFile"'; \
	} > /etc/ca-certificates/update.d/docker-openjdk; \
	chmod +x /etc/ca-certificates/update.d/docker-openjdk; \
	/etc/ca-certificates/update.d/docker-openjdk; \
	\
	find "$JAVA_HOME/lib" -name '*.so' -exec dirname '{}' ';' | sort -u > /etc/ld.so.conf.d/docker-openjdk.conf; \
	ldconfig; \
	\
# 查找新安装的应用依赖软件包，并标识为'manual'，防止后续自动清理时被删除
	apt-mark auto '.*' > /dev/null; \
	{ [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; }; \
	find /usr/local -type f -executable -exec ldd '{}' ';' \
		| awk '/=>/ { print $(NF-1) }' \
		| sort -u \
		| xargs -r dpkg-query --search \
		| cut -d: -f1 \
		| sort -u \
		| xargs -r apt-mark manual; \
	\
# 删除安装的临时依赖软件包，清理缓存
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false ${fetchDeps}; \
	apt-get autoclean -y; \
	rm -rf /var/lib/apt/lists/*; \
	\
# 验证安装的软件是否可以正常运行，常规情况下放置在命令行的最后
	javac -version; \
	java -version;


CMD [ "/bin/bash" ]
