FROM openjdk:8u151-jre-alpine

ARG kafka_version=2.12-2.2.0


ENV KAFKA_VERSION=$kafka_version
RUN mkdir /kafka /data

WORKDIR /kafka

ADD ./kafka_env.sh .

RUN apk add --no-cache curl wget bash && \
    wget http://mirror.cogentco.com/pub/apache/kafka/2.2.0/kafka_2.12-2.2.0.tgz -P /kafka && \
    tar -xzf /kafka/kafka_2.12-2.2.0.tgz -C /kafka --strip-components 1 && \
    chmod +x /kafka/kafka_env.sh 

VOLUME /data

EXPOSE 9092 19092

ENTRYPOINT ["/kafka/kafka_env.sh"]


CMD /kafka/bin/kafka-server-start.sh /kafka/config/server.properties
    
