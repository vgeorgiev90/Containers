FROM bde2020/hadoop-base

HEALTHCHECK CMD curl -f http://localhost:8485/ || exit 1

ENV HDFS_CONF_dfs_journalnode_data_dir=file:///hadoop/journalnode/data
RUN mkdir -p /hadoop/journalnode/data
VOLUME /hadoop/journalnode/data

ADD run.sh /run.sh
RUN chmod a+x /run.sh

EXPOSE 8485

CMD ["/run.sh"]
