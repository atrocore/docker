#!/bin/bash

source .env

if [ -z "$PRODUCTION_DOMAIN" ]; then
    echo "PRODUCTION_DOMAIN is not set in .env file"
    exit 1
fi

modify_container_files() {
    local domain=$1
    local container_name="web"

    docker compose exec $container_name bash -c "tee \"/etc/apache2/sites-available/${domain}.conf\" > /dev/null << EOL
<VirtualHost *:80>
  ServerName ${domain}
  DocumentRoot /var/www/${domain}/public
  <Directory /var/www/${domain}/public/>
    AllowOverride All
  </Directory>

  <IfModule php_module>
    php_admin_value memory_limit 256M
    php_admin_value max_execution_time 180
    php_admin_value max_input_time 180
    php_admin_value post_max_size 20M
    php_admin_value upload_max_filesize 20M
  </IfModule>

  ErrorLog \"|/usr/bin/rotatelogs /var/log/apache2/${domain}/error_%Y.%m.%d.log 5M\"
  CustomLog \"|/usr/bin/rotatelogs /var/log/apache2/${domain}/access_%Y.%m.%d.log 5M\" combined
</VirtualHost>
EOL"

    docker compose exec $container_name bash -c 'chown root /var/spool/cron/crontabs/www-data'
    docker compose exec $container_name bash -c "sed -i \"/\/var\/www\/${domain}\/.*\.php cron/d\" /var/spool/cron/crontabs/www-data"
    docker compose exec $container_name bash -c "echo \"* * * * * /usr/local/bin/php /var/www/${domain}/console.php cron\" >> /var/spool/cron/crontabs/www-data"
    docker compose exec $container_name bash -c 'chown www-data /var/spool/cron/crontabs/www-data'

    echo "Configuration updated for domain: ${domain}"
}

modify_container_files "$PRODUCTION_DOMAIN"

if [ ! -z "$TESTING_DOMAIN" ]; then
    modify_container_files "$TESTING_DOMAIN"
fi


docker compose exec web service apache2 reload
