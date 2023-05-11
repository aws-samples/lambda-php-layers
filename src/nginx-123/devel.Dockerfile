FROM public.ecr.aws/awsguru/devel

COPY --from=public.ecr.aws/awsguru/aws-lambda-adapter:0.7.0 /lambda-adapter /opt/extensions/

ENV NGINX_VERSION="1.23.3"

RUN cd /tmp \
    && curl -sL https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz | tar -xvz \
    && cd nginx-${NGINX_VERSION} \
    && ./configure \
       --prefix=/opt/nginx \
       --sbin-path=/opt/nginx/bin/nginx \
       --modules-path=/opt/nginx/modules \
       --pid-path=/tmp/nginx.pid \
       --error-log-path=/dev/stderr \
       --http-log-path=/dev/stdout \
       --http-client-body-temp-path=/tmp/client_body_temp \
       --http-proxy-temp-path=/tmp/proxy_temp \
       --http-fastcgi-temp-path=/tmp/fastcgi_temp \
       --http-uwsgi-temp-path=/tmp/uwsgi_temp \
       --http-scgi-temp-path=/tmp/scgi_temp \
       --with-http_ssl_module \
       --with-stream \
       --with-pcre=../pcre2-${PCRE2_VERSION} \
       --with-zlib=../zlib-${ZLIB_VERSION} \
       --with-openssl=../openssl-${OPENSSL_VERSION} \
    && make -j$(cat /proc/cpuinfo | grep "processor" | wc -l) \
    && make install --silent \
    && /lambda-layer copy_libs /opt/nginx/bin/nginx \
    && ln -s /opt/nginx/bin/nginx /usr/bin \
    && yum clean all \
    && rm -rf /var/cache/yum \
    && rm -rf /tmp/*

# config files
ADD nginx/conf/nginx.conf /opt/nginx/conf/nginx.conf

# code files
COPY app /var/task/app

COPY runtime/bootstrap /opt/bootstrap

COPY runtime/bootstrap /var/runtime/bootstrap

RUN chmod 0755 /opt/bootstrap  \
    && chmod 0755 /var/runtime/bootstrap

ENTRYPOINT /var/runtime/bootstrap
