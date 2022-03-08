# postresql-upgrade

## About

Upgrade PostgreSQL database into an other database using a simple `docker run`

## Usage

This Docker image run pg_upgrade by default

CMD can be override using `psql` or `bash` or any commands available in
official PostgreSQL docker image. In this case the new database will be
prepared but pg_upgrade will not be run

Default values:

* PGUSER=postgres

Required variables:

* PG_NEW (Upgrade to 9.3, 10, 12,...)

Discovered variables:

* PG_OLD (from /pg_old/data/PG_VERSION file)
* ENCODING (from old $PGUSER database)
* LOCALE (from old $PGUSER database)

```bash
docker run -t -i \
  -e PG_NEW=13 \
  -e PGUSER=postgres \
  -v /pg/data:/pg_old/data \
  -v /pg_new/data:/pg_new/data \
  bareos/postgresql-upgrade:latest
```

## Troubleshooting

Would like to use `bash` to debug. Target database will be prepared only (no pg_upgrade)

```bash
docker run -t -i \
  -e PG_NEW=13 \
  -e PGUSER=postgres \
  -v /pg/data:/pg_old/data \
  -v /pg_new/data:/pg_new/data \
  bareos/postgresql-upgrade:latest \
  /bin/bash
```

