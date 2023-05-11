FROM public.ecr.aws/awsguru/devel

COPY --from=public.ecr.aws/awsguru/nginx /opt /opt
COPY --from=public.ecr.aws/awsguru/aws-lambda-adapter:0.7.0 /lambda-adapter /opt/extensions/
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

ENV PHP_VERSION="7.4.33"

RUN cd /tmp && \
    curl -O https://www.php.net/distributions/php-$PHP_VERSION.tar.gz && \
    tar -zxf php-$PHP_VERSION.tar.gz && \
    cd php-$PHP_VERSION && \
    git clone https://github.com/phpredis/phpredis.git && \
    mv phpredis ext/redis && \
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
      --enable-shared=yes \
      --enable-cli=shared \
      --enable-fpm=shared \
      --with-fpm-user=nobody \
      --with-fpm-group=nobody \
      --with-bz2=shared \
      --with-pear=shared \
      --enable-ctype=shared \
      --with-curl=shared \
      --enable-dom=shared \
      --enable-exif=shared \
      --enable-fileinfo=shared \
      --enable-filter=shared \
      --enable-gd=shared \
      --with-gettext=shared \
      --with-iconv=shared \
      --enable-mbstring=shared \
      --enable-opcache=shared \
      --with-openssl=shared \
      --enable-pcntl=shared \
      --with-external-pcre=shared \
      --enable-pdo=shared \
      --with-pdo-mysql=shared \
      --enable-mysqlnd=shared \
      --with-pdo-sqlite=shared \
      --with-mysqli=shared \
      --enable-phar=shared \
      --enable-posix=shared \
      --with-readline=shared \
      --enable-session=shared \
      --enable-soap=shared \
      --enable-sockets=shared \
      --enable-sysvsem=shared\
      --enable-sysvshm=shared \
      --enable-tokenizer=shared\
      --with-libxml=shared \
      --enable-simplexml=shared \
      --enable-xml=shared \
      --enable-xmlreader=shared \
      --enable-xmlwriter=shared \
      --with-xsl=shared \
      --enable-ftp=shared \
      --enable-bcmath=shared \
      --with-zip=shared \
      --with-zlib=shared \
      --with-xmlrpc=shared \
      --enable-shmop=shared \
      --with-libedit=shared \
      --enable-calendar=shared \
      --enable-intl=shared \
      --with-pdo-pgsql=shared \
      --with-pgsql=shared \
      --enable-redis=shared \
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
    yes | pecl install -f igbinary && \
    pecl install -f imagick && \
    pecl install -f libsodium && \
    pecl install -f memcached && \
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
