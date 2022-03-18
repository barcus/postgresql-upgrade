# Bareos director Dockerfile
FROM postgres:14-bullseye

LABEL maintainer="barcus@tou.nu"

ARG PG_NEW

RUN apt-get update \
 && apt-get install -y sudo

RUN adduser postgres sudo
RUN echo '%postgres ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN mkdir -p /var/log/postgresql
WORKDIR /var/log/postgresql

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
