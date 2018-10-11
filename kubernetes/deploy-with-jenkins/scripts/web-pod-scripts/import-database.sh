#!/bin/bash

db_name="${1}"

mysql -h localhost -P3306 -uroot -pviktor123 ${db_name} < /mnt/databases/${db_name}.sql

if [ $? -eq 0 ];then
   rm /mnt/databases/"${db_name}".sql -rf
   echo "Database imported..."
else
   echo "Database was not imported..."
fi
