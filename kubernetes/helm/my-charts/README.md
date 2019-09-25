simple example for spark job submition when cluster is installed with helm chart

apiVersion: batch/v1
kind: Job
metadata:
  name: spark-test
  namespace: spark
spec:
  template:
    metadata:
      labels:
        app: spark-client
    spec:
      containers:
      - image: bde2020/spark-base:2.4.3-hadoop2.7
        name: job
        volumeMounts:
        - name: job
          mountPath: /tmp
        command:
        - bash
        - -c
        - ./spark/bin/spark-submit --class org.apache.spark.examples.SparkPi --master spark://spark-master:7077 --deploy-mode client --conf spark.driver.host=spark-client /tmp/spark-examples_2.11-2.4.4.jar
      volumes:
      - name: job
        hostPath:
          path: /root
      restartPolicy: Never



Ref: https://github.com/big-data-europe/docker-spark
