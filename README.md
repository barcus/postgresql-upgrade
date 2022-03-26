# postgresql-upgrade

## About

Upgrade PostgreSQL database into another database using a simple `docker run`

## Overview

It uses `pg_upgrade` binary from PostgreSQL docker image to upgrade.

It should work for any database version compliant with `pg_uprgade`

:+1: Tested from 9.3+ to [10-14] and more

:warning: `pg_upgrade` is not able to downgrade

## Requirements

* [Docker](https://docs.docker.com/install)

## Usage

This Docker image runs `pg_upgrade` as a default command.

Default command (CMD) can be overridden using `psql` or `bash` or any command
available in official PostgreSQL docker image. In this case new database is
initialized but `pg_upgrade` is not executed. (See troubleshooting section)

Either way, the command is run with postgres system user.

After successful upgrade, new database is available in `<pg_new_data>`
folder. In any case source database is not modified.

Docker volumes required:

* `/data/pg-old` (should contain source db)
* `/data/pg-new` (will contain target db)

See example below.

Variables:

* PGUSER=postgres (should exist in source database)

Optional:

* PG_NEW=14 (default v14)
* PG_OLD (discovered from source PG_VERSION file)
* ENCODING (discovered from source $PGUSER database)
* LOCALE (discovered from source $PGUSER database)

### Example

Let's say our source database is located in "/data/pg-old" and the target one
built in "/data/pg-new". Upgrade to PostgreSQL v13 with "postgres" as
a superuser.

```bash
docker run -t -i \
  -e PG_NEW=13 \
  -e PGUSER=postgres \
  -v /data/pg-old:/pg_old/data \
  -v /data/pg-new:/pg_new/data \
  barcus/postgresql-upgrade
```

## Build

Build your own image:

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
  -v /data/pg-old:/pg_old/data \
  -v /data/pg-new:/pg_new/data \
  my-postgresql-upgrade
```

## Troubleshooting

Would like to use `bash` to debug? In this case target database is prepared but
`pg_upgrade` is not ran.

```bash
docker run -t -i \
  -e PG_NEW=13 \
  -e PGUSER=postgres \
  -v /data/pg-old:/pg_old/data \
  -v /data/pg-new:/pg_new/data \
  barcus/postgresql-upgrade \
  /bin/bash
```

