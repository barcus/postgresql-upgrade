# Bareos director Dockerfile
FROM postgres:14-bullseye

LABEL maintainer="barcus@tou.nu"

ARG PG_NEW
ENV PG_ADMIN "root"

RUN mkdir /var/log/postgres

RUN apt-get update \
 && apt-get install -y sudo

RUN adduser postgres sudo
RUN echo '%postgres ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

WORKDIR /var/log/postgres

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
