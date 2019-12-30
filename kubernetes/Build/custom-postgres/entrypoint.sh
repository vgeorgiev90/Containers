#!/usr/bin/env bash
set -Eeo pipefail

echo "STARTED WITH DATA VERSION ($VERSION_NUMBER)"

if [ ! $PGDATA ]; then
  echo "PGDATA is not set"
  exit -9
fi

if [ $LOAD_DATA ]; then
    echo "CHECKING FOR OLD DATA"
    if [ ! -f $PGDATA/loaded-$VERSION_NUMBER ]; then
        echo "REMOVING OLD DATA"
        rm -rf $PGDATA/* || true
        echo "OLD DATA REMOVED"
    fi
fi

source /usr/local/bin/docker-entrypoint.sh