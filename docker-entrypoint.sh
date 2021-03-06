#!/usr/bin/env bash
#set -x

: "${PGUSER:=postgres}"
: "${PG_NEW:=14}"
: "${DB_INIT:=true}"
PG_OLD=$(cat /pg_old/data/PG_VERSION)

re='^[0-9]+([.][0-9]+)?$'
if ! [[ ${PG_OLD} =~ $re ]] ; then
   echo "ERROR: version not found in file /pg_old/data/PG_VERSION" >&2; exit 1
fi

export PGBINOLD=/usr/lib/postgresql/${PG_OLD}/bin
export PGBINNEW=/usr/lib/postgresql/${PG_NEW}/bin
export PGDATAOLD=/pg_old/data
export PGDATANEW=/pg_new/data
export PGUSER="${PGUSER}"

if [ "$#" -eq 0 -o "${1:0:1}" = '-' ]; then
  set -- pg_upgrade
fi

if [ "$(id -u)" = '0' ] ;then
  echo "Found PostgreSQL ${PG_OLD} (OLD database)"
  # Install PG_OLD binaries
  echo "Installing binaries required"
  sed -i "s/$/ ${PG_OLD}/" /etc/apt/sources.list.d/pgdg.list
  apt-get update > /dev/null 2>&1
  apt-get install -y -qq --no-install-recommends \
    postgresql-${PG_OLD} postgresql-contrib-${PG_OLD} > /dev/null 2>&1
  echo "PostgreSQL ${PG_OLD} binaries installed"
  
  # Install PG_NEW binaries
  sed -i "s/$/ ${PG_NEW}/" /etc/apt/sources.list.d/pgdg.list
  apt-get install -y -qq --no-install-recommends \
    postgresql-${PG_NEW} postgresql-contrib-${PG_NEW} > /dev/null 2>&1
  echo "PostgreSQL ${PG_NEW} binaries installed"

  mkdir -p "$PGDATAOLD" "$PGDATANEW"
  chmod 700 "$PGDATAOLD" "$PGDATANEW"
  chown -R postgres "$PGDATAOLD" "$PGDATANEW"
  chown postgres .
  exec gosu postgres "$BASH_SOURCE" "$@"
fi

# Collect information from PG_OLD
# Start DB PG_OLD
eval "${PGBINOLD}/pg_ctl -D ${PGDATAOLD} -l logfile start"
# Wait for init
sleep 3
# Get default DB encoding and local
ENCODING=$(eval "${PGBINOLD}/psql -t $PGUSER -c 'SHOW SERVER_ENCODING'")
LOCALE=$(eval "${PGBINOLD}/psql -t $PGUSER -c 'SHOW LC_COLLATE'")
export ENCODING=$(echo ${ENCODING}| xargs)
export LOCALE=$(echo ${LOCALE}| xargs)
# Stop DB PG_OLD
eval "${PGBINOLD}/pg_ctl -D ${PGDATAOLD} -l logfile stop"

# Init DB PG_NEW  
if [ "${DB_INIT}" == 'true' ]; then
  ENCODING="${ENCODING:=SQL_ASCII}"
  LOCALE="${LOCALE:=en_US.utf8}"
  eval "${PGBINNEW}/initdb --username=${PGUSER} --pgdata=${PGDATANEW} --encoding=${ENCODING} --lc-collate=${LOCALE} --lc-ctype=${LOCALE}"
fi

# run pg_upgrade or launch CMD
if [ "$1" = 'pg_upgrade' ] ;then
  # Upgrade DB PG_OLD into PG_NEW
  eval "/usr/lib/postgresql/${PG_NEW}/bin/pg_upgrade"
else
  exec "$@"
fi

## Update pg config listen_address
#sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" ${PGDATANEW}/postgresql.conf
#
## Update pg_hba for docker (to improve)
#cat << EOF >> ${PGDATANEW}/pg_hba.conf
#host	all		all		192.168.0.0/16		trust
#host	all		all		172.17.0.0/16		trust
#EOF
#chown postgres:postgres ${PGDATANEW}/pg_hba.conf
