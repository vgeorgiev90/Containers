#!/bin/bash

## Add the repo
helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com/
helm repo update
### Install elastic search

### Make sure that you specify the storage class in values.yml for elasticsearch-data pod
## helm fetch incubator/elasticsearch
## data:
##  persistence:
##    enabled: true
##    accessMode: ReadWriteOnce
##    name: data
##    size: "30Gi"
##    storageClass: "glusterfs"
## helm install incubator/elasticsearch --namespace logging --name elasticsearch --set data.terminationGracePeriodSeconds=0 -f values.yml
helm install incubator/elasticsearch --namespace logging --name elasticsearch --set data.terminationGracePeriodSeconds=0 -f values.yml

## fluentd install
helm install --name fluentd --namespace logging stable/fluentd-elasticsearch --set elasticsearch.host=elasticsearch-client.logging.svc.cluster.local,elasticsearch.port=9200

## kibana install
helm install --name kibana --namespace logging stable/kibana --set env.ELASTICSEARCH_URL=http://elasticsearch-client.logging.svc.cluster.local:9200,env.SERVER_BASEPATH=/api/v1/namespaces/logging/services/kibana/proxy

## Reference  https://platform9.com/blog/kubernetes-logging-and-monitoring-the-elasticsearch-fluentd-and-kibana-efk-stack-part-2-elasticsearch-configuration/
