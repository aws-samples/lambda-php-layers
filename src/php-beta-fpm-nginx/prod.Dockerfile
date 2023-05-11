ARG DEVEL_TAG
ARG ARCH

FROM public.ecr.aws/awsguru/aws-lambda-adapter:0.7.0 AS adapter
FROM public.ecr.aws/awsguru/php-beta:$DEVEL_TAG-$ARCH AS builder

# Your builders code here
# You can install or disable some extensions
# RUN pecl install intl
RUN /lambda-layer php_disable shmop \
                              calendar \
                              xmlrpc \
                              sysvsem \
                              sysvshm \
                              pdo_pgsql \
                              pgsql \
                              bz2 \
                              intl \
                              && \
    /lambda-layer php_release

FROM public.ecr.aws/lambda/provided:al2

COPY --from=builder /lambda-layer   /lambda-layer
COPY --from=builder /opt            /opt
COPY --from=adapter /lambda-adapter /opt/extensions/

# code files
COPY app /var/task/app

RUN ln -s /opt/nginx/bin/nginx /usr/bin && \
    ln -s /opt/php/bin/php /usr/bin && \
    ln -s /opt/php/bin/php-fpm /usr/bin && \
    /lambda-layer clean_libs

ENTRYPOINT /opt/bootstrap
