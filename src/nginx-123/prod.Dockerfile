ARG DEVEL_TAG

FROM public.ecr.aws/awsguru/devel AS devel
FROM public.ecr.aws/awsguru/aws-lambda-adapter:0.7.0 AS adapter
FROM public.ecr.aws/awsguru/nginx:$DEVEL_TAG AS nginx

FROM public.ecr.aws/lambda/provided:al2

COPY --from=devel   /lambda-layer   /lambda-layer
COPY --from=nginx   /opt            /opt
COPY --from=adapter /lambda-adapter /opt/extensions/
COPY --from=nginx   /var/runtime    /var/runtime

# code files
COPY app /var/task/app

RUN ln -s /opt/nginx/bin/nginx /usr/bin && \
    /lambda-layer clean_libs

ENTRYPOINT /var/runtime/bootstrap
