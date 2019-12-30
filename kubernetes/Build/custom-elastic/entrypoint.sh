#!/bin/bash

set -e

if [ $LOAD_DATA ]; then

    if [ ! $VERSION_NUMBER ]; then
        echo "Missing VERSION_NUMBER environment variable" 
        exit -9
    fi

    DATA_DIR=/usr/share/elasticsearch/data/
    FILE_NAME=$VERSION_NUMBER-esemb.tar.gz
    CLUSTER_NAME=elasticsearch-cluster
    FILE_PATH=$DATA_DIR$VERSION_NUMBER-esemb.tar.gz

    echo "CHECKING FOR OLD DATA"
    if [ ! -f $DATA_DIR/loaded-$VERSION_NUMBER ]; then
        echo "REMOVING OLD DATA"
        rm -rf $DATA_DIR*
        echo "OLD DATA REMOVED"
    fi

    mkdir -p $DATA_DIR$CLUSTER_NAME

    # if [ -f $FILE_PATH ]; then
    #     if [ ! $SHA256_HASH"  "$FILE_PATH = "$(sha256sum $FILE_PATH)" ]; then
    #         echo "HASHES DON'T MATCH - REMOVING FILE"
    #         rm -rf $FILE_PATH
    #     fi
    # fi

    if [ ! -f $FILE_PATH ]; then
        echo "DOWNLOAD DATA $FILEE_NAME"
        az login --service-principal -u $AZ_USER -p $AZ_PASS --tenant $AZ_TENANT
        az storage blob download --verbose -f $FILE_PATH -c embdata -n $FILE_NAME --account-name $AZ_ACNAME
        # if [ ! $SHA256_HASH"  "$FILE_PATH = "$(sha256sum $FILE_PATH)" ]; then
        #     echo "HASHES DON'T MATCH - ABORTING"
        #     exit -9
        # fi
        pushd $DATA_DIR
        rm -rf $DATA_DIR$CLUSTER_NAME
        tar -xvzf $FILE_PATH
        touch $DATA_DIR/loaded-$VERSION_NUMBER
        popd
    fi

fi

echo "START ES"

exec "$@"