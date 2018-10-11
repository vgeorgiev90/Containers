#!/bin/bash

website_archive="${1}"
deploy_mysql="${2}"
deploy_web="${3}"
db_name="${4}"

pod=`kubectl get pods | grep ${deploy_web} | head -1 | head -1 | awk '{print $1}'`
pod_mysql=`kubectl get pods | grep ${deploy_mysql} | head -1 | head -1 | awk '{print $1}'`

echo "Executing on pod: ${pod}"
sleep 120
kubectl exec ${pod} /mnt/migrate-wordpress.sh ${website_archive} ${deploy_mysql} ${db_name} -n deploy
sleep 60
kubectl exec ${pod_mysql} /mnt/import-database.sh ${db_name}
sleep 30
for i in `kubectl get pods -n deploy | grep ${deploy_web} | awk '{print $1}'`;do kubectl exec $i /mnt/start.sh -n deploy;done

