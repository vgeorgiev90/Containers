#!/bin/bash

helm repo add coreos https://s3-eu-west-1.amazonaws.com/coreos-charts/stable/
helm install coreos/prometheus-operator --name prometheus-operator --namespace monitoring
helm install coreos/kube-prometheus --name kube-prometheus --set global.rbacEnable=true --namespace monitoring

kubectl port-forward $(kubectl get  pods --selector=app=kube-prometheus-grafana -n  monitoring --output=jsonpath="{.items..metadata.name}") -n monitoring  3000
