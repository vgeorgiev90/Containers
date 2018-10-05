#!/bin/bash

kubectl apply -f el-ss-service.yml
sleep 5
kubectl apply -f elastic-ss.yml

helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com/
helm repo update


helm install --name fluentd --namespace logging stable/fluentd-elasticsearch --set elasticsearch.host=es.logging.svc.cluster.local,elasticsearch.port=9200
sleep 5
helm install --name kibana --namespace logging stable/kibana --set env.ELASTICSEARCH_URL=http://es.logging.svc.cluster.local:9200,env.SERVER_BASEPATH=/api/v1/namespaces/logging/services/kibana/proxy

## Reference  https://platform9.com/blog/kubernetes-logging-and-monitoring-the-elasticsearch-fluentd-and-kibana-efk-stack-part-2-elasticsearch-configuration/
