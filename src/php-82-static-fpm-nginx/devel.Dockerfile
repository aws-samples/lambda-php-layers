FROM public.ecr.aws/awsguru/devel

COPY --from=public.ecr.aws/awsguru/nginx /opt /opt
COPY --from=public.ecr.aws/awsguru/aws-lambda-adapter:0.7.0 /lambda-adapter /opt/extensions/
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

ENV PHP_VERSION="8.2.2"

RUN cd /tmp && \
    curl -O https://www.php.net/distributions/php-$PHP_VERSION.tar.gz && \
    tar -zxf php-$PHP_VERSION.tar.gz && \
    cd php-$PHP_VERSION && \
    \
    git clone https://github.com/phpredis/phpredis.git &&  \
    mv phpredis ext/redis && \
    \
    curl -O https://pecl.php.net/get/igbinary-3.2.13.tgz && \
    tar -zxf igbinary-3.2.13.tgz && \
    mv igbinary-3.2.13 ext/igbinary && \
    \
    curl -O https://pecl.php.net/get/imagick-3.7.0.tgz && \
    tar -zxf imagick-3.7.0.tgz && \
    mv imagick-3.7.0 ext/imagick && \
    \
    curl -O https://pecl.php.net/get/libsodium-2.0.23.tgz && \
    tar -zxf libsodium-2.0.23.tgz && \
    rm -rf ext/sodium && \
    mv libsodium-2.0.23 ext/sodium && \
    \
    ./buildconf --force && \
    ./configure \
      --prefix=/opt/php \
      --with-config-file-path=/opt/php \
      --bindir=/opt/php/bin \
      --sbindir=/opt/php/bin \
      --with-config-file-scan-dir=/opt/php/php.d \
      --localstatedir=/tmp \
      --mandir=/tmp \
      --docdir=/tmp \
      --htmldir=/tmp \
      --dvidir=/tmp \
      --pdfdir=/tmp \
      --psdir=/tmp \
      --enable-static=yes \
      --enable-cli=static \
      --enable-fpm=static \
      --with-fpm-user=nobody \
      --with-fpm-group=nobody \
      --without-bz2 \
      --with-pear=static \
      --enable-ctype=static \
      --with-curl=static \
      --enable-dom=static \
      --enable-exif=static \
      --enable-fileinfo=static \
      --enable-filter=static \
      --enable-gd=static \
      --with-gettext=static \
      --with-iconv \
      --enable-mbstring=static \
      --enable-opcache=static \
      --with-openssl=static \
      --enable-pcntl=static \
      --with-external-pcre=static \
      --enable-pdo=static \
      --with-pdo-mysql \
      --enable-mysqlnd=static \
      --with-pdo-sqlite=static \
      --with-mysqli \
      --enable-phar=static \
      --enable-posix \
      --with-readline=static \
      --enable-session=static \
      --enable-soap=static \
      --enable-sockets=static \
      --enable-tokenizer=static\
      --with-libxml=static \
      --enable-simplexml=static \
      --enable-xml=static \
      --enable-xmlreader=static \
      --enable-xmlwriter=static \
      --with-xsl=static \
      --enable-ftp \
      --enable-bcmath=static \
      --with-zip=static \
      --with-zlib=static \
      --with-imagick=static \
      --enable-igbinary=static \
      --enable-redis-igbinary=static \
      --enable-redis=static \
      --with-sodium=static \
      --disable-shmop \
      --without-libedit \
      --disable-calendar \
      --disable-intl \
      --without-pdo-pgsql \
      --without-pgsql \
      && \
    make -j$(cat /proc/cpuinfo | grep "processor" | wc -l) && \
    make install && \
    for bin in $(ls /opt/php/bin); do \
        ln -s /opt/php/bin/$bin /usr/bin ; \
    done && \
    \
    ln -s /opt/nginx/bin/nginx /usr/bin && \
    \
    /lambda-layer change_ext_dir && \
    /lambda-layer php_enable_extensions && \
    \
    cd /tmp && \
    git clone --recursive https://github.com/awslabs/aws-crt-php.git && \
    cd aws-crt-php &&  \
    phpize && \
    ./configure && \
    make -j$(cat /proc/cpuinfo | grep "processor" | wc -l) && \
    make install && \
    \
    /lambda-layer php_enable_extensions && \
    /lambda-layer php_copy_libs && \
    \
    echo 'Clean Cache' && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    rm -rf /tmp/*

# config files
ADD nginx/conf/nginx.conf      /opt/nginx/conf/nginx.conf
ADD php/php.ini                /opt/php/php.ini
ADD php/etc/php-fpm.conf       /opt/php/etc/php-fpm.conf

# code files
COPY app /var/task/app

COPY runtime/bootstrap /opt/bootstrap

# Copy files to /var/runtime to support deploying as a Docker image
COPY runtime/bootstrap /var/runtime/bootstrap

RUN chmod 0755 /opt/bootstrap  \
    && chmod 0755 /var/runtime/bootstrap

ENTRYPOINT /var/runtime/bootstrap
