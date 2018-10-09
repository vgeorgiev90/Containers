#!/bin/bash


### Get the metrics-server repo
git clone https://github.com/kubernetes-incubator/metrics-server.git

## Add the following to /root/metrics-server/deploy/1.8+/metrics-server-deployment.yaml   to fix the name resolution of nodes
#command:
#- /metrics-server
#- --kubelet-insecure-tls
#- --kubelet-preferred-address-types=InternalIP

kubectl create -f metrics-server/deploy/1.8+

## kubectl autoscale rc NAME --min=2 --max=5 --cpu-percent=80
## kubectl get hpa

## Refference: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/
