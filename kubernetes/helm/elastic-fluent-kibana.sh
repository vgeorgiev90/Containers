#!/bin/bash

## Install elk stack with helm

helm repo add akomljen-charts https://raw.githubusercontent.com/komljen/helm-charts/master/charts/

# es-operator deploy
helm install --name es-operator --namespace logging --set rbac.create=true akomljen-charts/elasticsearch-operator

# deploy the stack
helm install --name efk --namespace logging akomljen-charts/efk

#Create ingress for the kibana service on port 5601

##reference 
# https://akomljen.com/get-kubernetes-logs-with-efk-stack-in-5-minutes/
