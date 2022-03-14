# postgresql-upgrade

## About

Upgrade PostgreSQL database into another database using a simple `docker run`

## Usage

This Docker image runs pg_upgrade by default.

CMD can be overridden using `psql` or `bash` or any commands available in
official PostgreSQL docker image. In this case the new database will be
prepared but pg_upgrade will not be run.

After successful upgrade, the new database will be available in `<pg_new_data>`
folder. Old database should not be modified.

Docker volumes required (check example below) :

* `<pg_old_data>`:/pg_old/data
* `<pg_new_data>`:/pg_new/data

Required variables (check example below):

* PGUSER (should exist in old instance)

Optional variables:

* PG_NEW=14

Discovered variables:

* PG_OLD (from /pg_old/data/PG_VERSION file)
* ENCODING (from old $PGUSER database)
* LOCALE (from old $PGUSER database)

### Example

```bash
docker run -t -i \
  -e PG_NEW=13 \
  -e PGUSER=postgres \
  -v /pg/data:/pg_old/data \
  -v /pg_new/data:/pg_new/data \
  barcus/postgresql-upgrade:latest
```

### Build

Build you own image:

```bash
git clone https://github.com/barcus/postgresql-upgrade.git
cd postgresql-upgrade
docker build -t my-postgresql-upgrade .
```

Then use it:

```bash
docker run -t -i \
  -e PG_NEW=13 \
  -e PGUSER=postgres \
  -v /pg/data:/pg_old/data \
  -v /pg_new/data:/pg_new/data \
  my-postgresql-upgrade
```

## Troubleshooting

Would like to use `bash` to debug? Target database will be prepared only (no pg_upgrade)

```bash
docker run -t -i \
  -e PG_NEW=13 \
  -e PGUSER=postgres \
  -v /pg/data:/pg_old/data \
  -v /pg_new/data:/pg_new/data \
  barcus/postgresql-upgrade:latest \
  /bin/bash
```

