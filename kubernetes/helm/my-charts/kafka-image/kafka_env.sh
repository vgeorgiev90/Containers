#!/bin/sh

ID=`eval ${ID_COMMAND}`
HOST=`eval ${HOSTNAME_COMMAND}`
ZOOS=${ZOOKEEPER_CONNECT}

conf_file='/kafka/config/server.properties'


sed -i "s/broker.id=.*/broker.id=${ID}/" $conf_file
sed -i "s/zookeeper.connect=localhost:2181/zookeeper.connect=${ZOOS}/" $conf_file
sed -i "s/log.dirs=\/tmp\/kafka-logs/log.dirs=\/data/" $conf_file

LISTENERS="INTERNAL://${HOST}:19092,OUTSIDE://${HOST}:9092"

LPM="listener.security.protocol.map=INTERNAL:PLAINTEXT,OUTSIDE:PLAINTEXT"
LISTENER="listeners=${LISTENERS}"
ADVERTISE="advertised.listeners=${LISTENERS}"
INTER_BROKER="inter.broker.listener.name=INTERNAL"

echo "" >> $conf_file
echo $INTER_BROKER >> $conf_file
echo $LPM >> $conf_file
echo $LISTENER >> $conf_file
echo $ADVERTISE >> $conf_file


nc -z ${HOST} 9092
result=$?

until [ $result -eq 0 ]; do
	echo "Waiting for endpoint to become ready..."
	sleep 5
	nc -z ${HOST} 9092
        result=$?
done


exec "$@"
