#!/bin/bash

web=${1}
mysql=${2}

sed "s/web/${web}/g" /var/lib/jenkins/kubernetes/deploy-pvc.yml > /var/lib/jenkins/kubernetes/pvc.tmp
sed -i "s/mysql/${mysql}/g" /var/lib/jenkins/kubernetes/pvc.tmp
kubectl create -f /var/lib/jenkins/kubernetes/pvc.tmp
sleep 5
rm /var/lib/jenkins/kubernetes/pvc.tmp -rf


