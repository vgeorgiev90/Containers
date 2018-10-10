#!/bin/bash


deploy_web="${1}"
db_host="${2}"
db_name="${3}"
db_user="${4}"
db_pass="${5}"
domain="${6}"

pod=`kubectl get pods | grep ${deploy_web} | head -1 | head -1 | awk '{print $1}'`
echo "Executing on pod: ${pod}"
sleep 120
kubectl exec ${pod} /mnt/deploy-and-start.sh ${db_name} ${db_user} ${db_pass} ${db_host} ${domain} -n deploy
sleep 60
for i in `kubectl get pods -n deploy | grep ${deploy_web} | awk '{print $1}'`;do kubectl exec $i /mnt/start.sh -n deploy;done

