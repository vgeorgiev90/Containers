#!/bin/bash

website_archive="${1}"
website=`echo ${website_archive} | awk -F".tar.gz" '{print $1}'`

domain=`echo ${website_archive} | awk -F".tar.gz" '{print $1}' | awk -F"www." '{print $2}'`

mysql_host="${2}"
db_name="${3}"

wget http://10.0.11.155/"${website_archive}" -P /usr/share/nginx/html
echo "Wordpress archive downloaded....."
tar -xzf /usr/share/nginx/html/"${website_archive}" -C /usr/share/nginx/html
mv /usr/share/nginx/html/"${website}"/* /usr/share/nginx/html/.
rm /usr/share/nginx/html/"${website}" -rf && rm /usr/share/nginx/html/"${website_archive}" -rf
mv /usr/share/nginx/html/"${db_name}".sql /mnt/databases/"${db_name}".sql

echo "Wordpress extracted..."

sed -i "s/\"db_host\": \".*\"/\"db_host\": \"${mysql_host}\"/g" /usr/share/nginx/html/wp-config.json


cat > /usr/share/nginx/html/example-com.conf << EOF
server {
listen 80;
server_name www.${domain} www2.${domain};
root   /usr/share/nginx/html;
index  index.php index.html index.htm;
include /etc/nginx/wordpress.conf;
include /etc/nginx/limits.conf;
}
EOF

chown -R nginx:nginx /usr/share/nginx/html

