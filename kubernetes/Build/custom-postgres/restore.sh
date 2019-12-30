#!/usr/bin/env bash
set -Eeo pipefail

if [ ! $PGDATA ]; then
  echo "PGDATA is not set"
  exit -9
fi

echo "CHECKING IF SHOULD LOAD DATA"

if [ $LOAD_DATA ]; then

    echo "LOAD DATA"

    if [ ! $VERSION_NUMBER ]; then
        echo "Missing VERSION_NUMBER environment variable" 
        exit -9
    fi

    FILE_NAME=$VERSION_NUMBER-pgemb.sql
    FILE_PATH=$PGDATA/$VERSION_NUMBER-pgemb.sql

    if [ ! -f $FILE_PATH ]; then
        echo "DOWNLOAD DATA"
        mkdir -p $PGDATA || true
        az login --service-principal -u $AZ_USER -p $AZ_PASS --tenant $AZ_TENANT
        az storage blob download --verbose -f $FILE_PATH -c embdata -n $FILE_NAME --account-name $AZ_ACNAME
    fi

    if [ ! -f $PGDATA/loaded-$VERSION_NUMBER ]; then
        echo "LOADING DATA"
        pushd $PGDATA
        PGPASSWORD=$POSTGRES_PASSWORD pg_restore -d emb -U postgres < $FILE_PATH
        popd
        echo "DATA LOADED"
        touch $PGDATA/loaded-$VERSION_NUMBER
    fi

fi