from jenkins/jenkins:latest

#Install some jenkins plugins
RUN /usr/local/bin/install-plugins.sh ssh-slaves
RUN /usr/local/bin/install-plugins.sh email-ext
RUN /usr/local/bin/install-plugins.sh mailer
RUN /usr/local/bin/install-plugins.sh slack
RUN /usr/local/bin/install-plugins.sh htmlpublisher
RUN /usr/local/bin/install-plugins.sh simple-theme-plugin
RUN /usr/local/bin/install-plugins.sh kubernetes
RUN /usr/local/bin/install-plugins.sh build-pipeline-plugin
RUN /usr/local/bin/install-plugins.sh kubernetes-pipeline-devops-steps
RUN /usr/local/bin/install-plugins.sh kubernetes-pipeline-steps
RUN /usr/local/bin/install-plugins.sh workflow-aggregator

#Install maven
USER root
RUN apt-get update -y && apt-get install maven -y
USER jenkins
