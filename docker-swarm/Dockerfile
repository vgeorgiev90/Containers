# Example docker file
ARG TAG=latest
FROM centos:${TAG}

LABEL maintainer="someone@somedomain.com"

RUN yum update -y && yum install httpd net-tools -y && mkdir -p /run/httpd
RUN echo "INDEX FILE" > /var/www/html/index.html && chown apache: /var/www/html/index.html

CMD echo "Check your container IP address"

EXPOSE 80

ENTRYPOINT apachectl "-DFOREGROUND"
