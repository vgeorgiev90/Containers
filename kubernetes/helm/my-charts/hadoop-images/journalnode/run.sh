#!/bin/bash

datadir=`echo $HDFS_CONF_dfs_journalnode_data_dir | perl -pe 's#file://##'`
if [ ! -d $datadir ]; then
  echo "Journalnode data directory not found: $datadir"
  exit 2
fi

$HADOOP_PREFIX/bin/hdfs --config $HADOOP_CONF_DIR journalnode
