#!/bin/bash

ln -s /usr/share/nginx/html/example-com.conf /etc/nginx/conf.d/example-com.conf
/usr/sbin/php-fpm7.0
/usr/sbin/nginx -s reload
