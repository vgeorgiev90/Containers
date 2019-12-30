FROM postgres:11.5-alpine

# ARG MICROSCANNER_TOKEN
# RUN if [ -z "$MICROSCANNER_TOKEN" ]; then echo "MICROSCANNER_TOKEN not set using --build-arg MICROSCANNER_TOKEN=<token>"; exit 1; else : ; fi

USER root

## Install Azure CLI
RUN apk update
RUN apk add --no-cache ca-certificates && update-ca-certificates
RUN apk add bash py-pip
RUN apk add --virtual=build gcc libffi-dev musl-dev openssl-dev python-dev make
RUN pip --no-cache-dir install -U pip
RUN pip --no-cache-dir install azure-cli
RUN apk del --purge build
RUN apk upgrade
RUN apk add nss

COPY ./restore.sh /docker-entrypoint-initdb.d/restore.sh
RUN chmod 755 /docker-entrypoint-initdb.d/restore.sh
RUN chown postgres /docker-entrypoint-initdb.d/restore.sh

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
RUN chown postgres /entrypoint.sh

COPY ./healthcheck.sh /healthcheck.sh
RUN chmod +x /healthcheck.sh
RUN chown postgres /healthcheck.sh

USER postgres

# RUN wget -O /microscanner https://get.aquasec.com/microscanner && \
#     chmod +x /microscanner
# RUN [ "8e01415d364a4173c9917832c2e64485d93ac712a18611ed5099b75b6f44e3a5  /microscanner" = "$(sha256sum /microscanner)" ]
# RUN /microscanner --continue-on-failure $MICROSCANNER_TOKEN && \
#     rm -rf /microscanner

ENV PGDATA /var/lib/postgresql/data

HEALTHCHECK CMD ["/healthcheck.sh"]

ENTRYPOINT ["/entrypoint.sh"]

CMD ["postgres"]