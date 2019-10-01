#!/bin/bash

namedir=`echo $HDFS_CONF_dfs_namenode_name_dir | perl -pe 's#file://##'`
if [ ! -d $namedir ]; then
  echo "Namenode name directory not found: $namedir"
  exit 2
fi

if [ -z "$CLUSTER_NAME" ]; then
  echo "Cluster name not specified"
  exit 2
fi

HOSTNAME=$(hostname)
if [ ${HOSTNAME} == "hadoop-namenode-0" ]; then
  echo "Formatting namenode name directory: $namedir"
  $HADOOP_PREFIX/bin/hdfs --config $HADOOP_CONF_DIR namenode -format $CLUSTER_NAME 
else
  $HADOOP_PREFIX/bin/hdfs namenode -bootstrapStandby
fi

$HADOOP_PREFIX/bin/hdfs --config $HADOOP_CONF_DIR namenode
