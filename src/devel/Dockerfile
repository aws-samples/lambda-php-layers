FROM public.ecr.aws/lambda/provided:al2

COPY lambda-layer /

ARG ARCH

ENV OPENSSL_VERSION="1.1.1p"
ENV PCRE2_VERSION="10.40"
ENV ZLIB_VERSION="1.2.13"
ENV PKG_CONFIG_PATH=/usr/local/pcre2/lib/pkgconfig/

RUN if [[ $ARCH == "x86_64" ]]; then \
    yum install -y \
                https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
                https://rpms.remirepo.net/enterprise/remi-release-7.rpm \
                yum-utils \
                epel-release \
                msgpack-devel \
                libmcrypt-devel \
                mhash-devel \
                libtidy-devel \
    ; fi \
    && yum install -y \
                unzip \
                curl \
                tar \
                gzip \
                make \
                cmake \
                cmake3 \
                autoconf \
                gcc \
                gcc-c++ \
                vi \
                vim-common \
                which \
                libxslt-devel \
                libjpeg-devel \
                libpng-devel \
                freetype-devel \
                libxml2-devel \
                zlib-devel \
                glibc-devel \
                curl-devel \
                libidn-devel \
                openssl-devel \
                sqlite-devel \
                libcurl-devel \
                libpng-devel \
                libjpeg-devel \
                freetype-devel \
                libicu-devel \
                oniguruma-devel \
                libxslt-devel \
                libzstd-devel \
                ImageMagick-devel \
                libmemcached-devel \
                postgresql-devel \
                libedit-devel \
                net-snmp-devel \
                pcre2-devel  \
                enchant-devel  \
                libffi-devel \
                gmp-devel \
                pam-devel \
                openldap-devel \
                libiodbc-devel \
                postgresql-devel \
                readline-devel \
                net-snmp-devel \
                libzip-devel \
                mysql-devel \
                glibc-static \
    && export CPU_NUM=$(cat /proc/cpuinfo | grep "processor" | wc -l) \
    \
    && cd /tmp \
    && curl -sL https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz | tar -xvz > /dev/null \
    && cd openssl-${OPENSSL_VERSION} \
    && if [[ $ARCH == "arm64" ]]; then ./Configure linux-aarch64 --prefix=/tmp/openssl ; fi \
    && if [[ $ARCH == "x86_64" ]]; then ./Configure linux-x86_64 --prefix=/tmp/openssl ; fi \
    && echo '---- Install openssl' \
    && make -j$CPU_NUM \
    && make install \
    \
    && cd /tmp \
    && curl -sL https://github.com/PCRE2Project/pcre2/releases/download/pcre2-${PCRE2_VERSION}/pcre2-${PCRE2_VERSION}.tar.gz | tar -xvz > /dev/null \
    && cd pcre2-${PCRE2_VERSION} \
    && ./configure --prefix=/usr/local/pcre2 \
    && make -j$CPU_NUM \
    && make install \
    \
    && cd /tmp \
    && curl -sL https://zlib.net/zlib-${ZLIB_VERSION}.tar.gz | tar -xvz > /dev/null \
    && cd zlib-${ZLIB_VERSION} \
    && ./configure --prefix=/tmp/zlib \
    && make -j$CPU_NUM \
    && make install \
    \
    && cd /tmp \
    && curl -sL https://download.libsodium.org/libsodium/releases/libsodium-1.0.17.tar.gz | tar -xvz > /dev/null \
    && cd libsodium-1.0.17 \
    && ./configure \
    && make -j$CPU_NUM \
    && make install \
    \
    && yum install -y openldap-devel \
    && cp -frp /usr/lib64/libldap* /usr/lib/ \
    \
    && yum groupinstall -y "Development Tools" \
    \
    && yum clean all \
    && rm -rf /var/cache/yum
