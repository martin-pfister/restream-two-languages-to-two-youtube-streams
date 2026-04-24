FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    nginx \
    libnginx-mod-rtmp \
    ffmpeg \
    gettext-base \
    && rm -rf /var/lib/apt/lists/*

# Copy as template, not the final config
COPY nginx.conf /etc/nginx/nginx.conf.template

CMD ["/bin/bash", "-c", \
    "envsubst '${YT_KEY_EN} ${YT_KEY_DE}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf && nginx -g 'daemon off;'"]

