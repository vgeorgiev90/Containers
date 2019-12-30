FROM alpine:3.9.2@sha256:644fcb1a676b5165371437feaa922943aaf7afcfa8bfee4472f6860aad1ef2a0

RUN apk update
RUN apk add openjdk8 curl

## Install Azure CLI

USER root
RUN apk update
RUN apk add bash py-pip
RUN apk add --virtual=build gcc libffi-dev musl-dev openssl-dev python-dev make
RUN pip --no-cache-dir install -U pip
RUN pip --no-cache-dir install azure-cli
RUN apk del --purge build
RUN apk upgrade
RUN apk add nss

RUN adduser -D -u 1000 -h /home/elasticsearch elasticsearch

COPY ./entrypoint.sh /
RUN chmod +x /entrypoint.sh
RUN chown elasticsearch /entrypoint.sh

COPY ./healthcheck.sh /
RUN chmod +x /healthcheck.sh
RUN chown elasticsearch /healthcheck.sh

RUN mkdir -p /usr/share/elasticsearch/data/elasticsearch-cluster
RUN chown elasticsearch /usr/share/elasticsearch/data/elasticsearch-cluster
RUN mkdir -p /var/log/elasticsearch/elasticsearch-cluster
RUN chown elasticsearch /var/log/elasticsearch/elasticsearch-cluster

USER elasticsearch

WORKDIR /home/elasticsearch

RUN curl -L -O https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.6.0.zip
RUN [ "07912e3d2e9d1a8f68ecac55f4290d563aa5e0b2af37e94db70e316e0cb262fb  elasticsearch-6.6.0.zip" = "$(sha256sum elasticsearch-6.6.0.zip)" ]
RUN unzip elasticsearch-6.6.0.zip

RUN ./elasticsearch-6.6.0/bin/elasticsearch-plugin install -b https://github.com/vvanholl/elasticsearch-prometheus-exporter/releases/download/6.6.0.0/prometheus-exporter-6.6.0.0.zip

COPY ./elasticsearch.yml /home/elasticsearch/elasticsearch-6.6.0/config/elasticsearch.yml

USER root

# RUN wget -O /microscanner https://get.aquasec.com/microscanner && \
#     chmod +x /microscanner
# RUN [ "8e01415d364a4173c9917832c2e64485d93ac712a18611ed5099b75b6f44e3a5  /microscanner" = "$(sha256sum /microscanner)" ]
# ARG MICROSCANNER_TOKEN
# RUN if [ -z "$MICROSCANNER_TOKEN" ]; then echo "MICROSCANNER_TOKEN not set using --build-arg MICROSCANNER_TOKEN=<token>"; exit 1; else : ; fi
# RUN /microscanner --continue-on-failure $MICROSCANNER_TOKEN && \
#     rm -rf /microscanner

USER elasticsearch

EXPOSE 9200
EXPOSE 9300

RUN rm -rf /home/elasticsearch/elasticsearch-6.6.0/modules/x-pack-ml

HEALTHCHECK CMD ["/healthcheck.sh"]

ENTRYPOINT ["/entrypoint.sh"]

CMD ./elasticsearch-6.6.0/bin/elasticsearch