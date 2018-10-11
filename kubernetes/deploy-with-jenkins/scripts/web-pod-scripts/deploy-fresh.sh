#!/bin/bash

db_name="${1}"
db_user="${2}"
db_pass="${3}"
db_host="${4}"
domain="${5}"

apt-get update && apt-get install curl wget vim -y

wget https://wordpress.org/latest.tar.gz -P /usr/share/nginx/html
echo "Wordpress downloaded...."
tar -xzf /usr/share/nginx/html/latest.tar.gz -C /usr/share/nginx/html
mv /usr/share/nginx/html/wordpress/* /usr/share/nginx/html
rm -rf /usr/share/nginx/html/latest.tar.gz && rm /usr/share/nginx/html/wordpress -rf
cp /usr/share/nginx/html/wp-config-sample.php /usr/share/nginx/html/wp-config.php

echo "Wordpress files setup complete.."

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
mv wp-cli.phar /usr/sbin/wp && chmod +x /usr/sbin/wp

domain_clear=`echo ${domain} | awk -F":" '{print $1}'`

admin_email="admin@${domain_clear}"


sed -i "s/database_name_here/${db_name}/" /usr/share/nginx/html/wp-config.php
sed -i "s/username_here/${db_user}/" /usr/share/nginx/html/wp-config.php
sed -i "s/password_here/${db_pass}/" /usr/share/nginx/html/wp-config.php
sed -i "s/localhost/${db_host}/" /usr/share/nginx/html/wp-config.php

echo "wp-config ready...."

cat > /usr/share/nginx/html/example-com.conf << EOF
server {
listen 80 default_server;
server_name ${domain_clear};
root /usr/share/nginx/html;
index index.php;

location / {
try_files \$uri \$uri/ /index.php?\$args;
}

location ~ \.php$ {
fastcgi_index index.php;
fastcgi_pass unix:/run/php/php7.0-fpm.sock;

include fastcgi_params;
fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
}
}
EOF

echo "WP vhost ready...."

wp core install --url=${domain} --title=Example --admin_user=admin --admin_password='P@$$word' --admin_email=${admin_email} --path=/usr/share/nginx/html --allow-root

chown -R nginx:nginx /usr/share/nginx/html

echo "Wordpress installed and ready....."

