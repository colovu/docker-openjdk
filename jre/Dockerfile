# Ver: 1.0 by Endial Fang (endial@126.com)
#
# 指定原始系统镜像，常用镜像为 colovu/ubuntu:18.04、colovu/debian:10、colovu/alpine:3.12、colovu/openjdk:8u252-jre
FROM colovu/debian:10

# ARG参数使用"--build-arg"指定，如 "--build-arg apt_source=tencent"
# sources.list 可使用版本：default / tencent / ustc / aliyun / huawei
ARG apt_source=default

# 编译镜像时指定本地服务器地址，如 "--build-arg local_url=http://172.29.14.108/dist-files/"
ARG local_url=""

ENV JAVA_VERSION=11.0.7 \
	JAVA_HOME=/usr/local/openjdk-11

ENV JRE_HOME="${JAVA_HOME}/jre" \
	CLASSPATH="${JAVA_HOME}/lib:${JAVA_HOME}/jre/lib:${CLASSPATH}" \
	PATH="${JAVA_HOME}/bin:${JAVA_HOME}/jre/bin:${PATH}"

LABEL \
	"Version"="v${JAVA_VERSION}" \
	"Description"="Docker image for openJDK jre-${JAVA_VERSION}." \
	"Dockerfile"="https://github.com/colovu/docker-openjdk" \
	"Vendor"="Endial Fang (endial@126.com)"

# 镜像内应用安装脚本
# 以下脚本可按照不同需求拆分为多个段，但需要注意各个段在结束前需要清空缓存
# set -eux: 设置 shell 执行参数，分别为 -e(命令执行错误则退出脚本) -u(变量未定义则报错) -x(打印实际待执行的命令行)
RUN set -eux; \
	\
# 设置程序使用静默安装，而非交互模式；类似tzdata等程序需要使用静默安装
	export DEBIAN_FRONTEND=noninteractive; \
	\
# 更改源为当次编译指定的源
	cp /etc/apt/sources.list.${apt_source} /etc/apt/sources.list; \
	\
	mkdir -p ${JAVA_HOME}; \
	\
# 应用软件包及依赖项。相关软件包在镜像创建完成时，不会被清理
	appDeps=" \
		p11-kit \
		ca-certificates \
	"; \
	\
	\
	\
# 安装临时使用的软件包及依赖项。相关软件包在镜像创建完后时，会被清理
	fetchDeps=" \
		bzip2 \
		unzip \
		xz-utils \
		\
		dirmngr \
		gnupg \
		\
		fontconfig \
		libfreetype6 \
		wget \
	"; \
	savedAptMark="$(apt-mark showmanual) ${appDeps}"; \
	apt-get update; \
	apt-get install -y --no-install-recommends ${fetchDeps} ${appDeps}; \
	\
	JAVA_URL_VERSION=11.0.7_10; \
	if [ -n "${local_url}" ]; then \
		JAVA_BASE_URL="${local_url}/OpenJDK11U-jre_"; \
	else \
		JAVA_BASE_URL="https://github.com/AdoptOpenJDK/openjdk11-upstream-binaries/releases/download/jdk-11.0.7%2B10/OpenJDK11U-jre_"; \
	fi; \
	wget -O  openjdk.tgz.asc "${JAVA_BASE_URL}x64_linux_${JAVA_URL_VERSION}.tar.gz.sign"; \
	wget -O  openjdk.tgz "${JAVA_BASE_URL}x64_linux_${JAVA_URL_VERSION}.tar.gz"; \	
	\
# 安装软件包需要使用的GPG证书，并验证软件
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
	rm -rf "${GNUPGHOME}"; \
	\
	tar --extract --file openjdk.tgz --strip-components 1 --no-same-owner --directory "${JAVA_HOME}"; \
	rm openjdk.tgz*; \
	\
	\
# update "cacerts" bundle to use Debian's CA certificates (and make sure it stays up-to-date with changes to Debian's store)
	{ \
		echo '#!/usr/bin/env bash'; \
		echo 'set -Eeuo pipefail'; \
		echo 'if ! [ -d "${JAVA_HOME}" ]; then echo >&2 "error: missing JAVA_HOME environment variable"; exit 1; fi'; \
# 8-jdk uses "${JAVA_HOME}/jre/lib/security/cacerts" and 8-jre and 11+ uses "${JAVA_HOME}/lib/security/cacerts" directly (no "jre" directory)
		echo 'cacertsFile=; for f in "${JAVA_HOME}/lib/security/cacerts" "${JAVA_HOME}/jre/lib/security/cacerts"; do if [ -e "$f" ]; then cacertsFile="$f"; break; fi; done'; \
		echo 'if [ -z "$cacertsFile" ] || ! [ -f "$cacertsFile" ]; then echo >&2 "error: failed to find cacerts file in ${JAVA_HOME}"; exit 1; fi'; \
		echo 'trust extract --overwrite --format=java-cacerts --filter=ca-anchors --purpose=server-auth "$cacertsFile"'; \
	} > /etc/ca-certificates/update.d/docker-openjdk; \
	chmod +x /etc/ca-certificates/update.d/docker-openjdk; \
	/etc/ca-certificates/update.d/docker-openjdk; \
	\
	find "${JAVA_HOME}/lib" -name '*.so' -exec dirname '{}' ';' | sort -u > /etc/ld.so.conf.d/docker-openjdk.conf; \
	ldconfig; \
	\
# 查找新安装的应用相应的依赖软件包，并标识为'manual'，防止后续自动清理时被删除
	apt-mark auto '.*' > /dev/null; \
	{ [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; }; \
	find /usr/local -type f -executable -exec ldd '{}' ';' \
		| awk '/=>/ { print $(NF-1) }' \
		| sort -u \
		| xargs -r dpkg-query --search \
		| cut -d: -f1 \
		| sort -u \
		| xargs -r apt-mark manual; \man
		\
# 删除临时软件包，清理缓存
	apt-get purge -y --auto-remove --force-yes -o APT::AutoRemove::RecommendsImportant=false ${fetchDeps}; \
	apt-get autoclean -y; \
	rm -rf /var/lib/apt/lists/*; \
	\
# 解决应用安装jre-headless时错误：update-alternatives: error: error creating symbolic link '/usr/share/man/man
	mkdir -p /usr/share/man/man1; \
	\
# 验证安装的软件是否可以正常运行，常规情况下放置在命令行的最后
	java --version;

CMD []
