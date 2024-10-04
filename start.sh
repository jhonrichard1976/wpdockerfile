#!/bin/bash

# Si wp-config.php no existe, crearlo usando wp-config-sample.php
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Creating wp-config.php file..."
    cp /usr/src/wordpress/wp-config-sample.php /var/www/html/wp-config.php
    sed -i "s/database_name_here/wordpress2008/" /var/www/html/wp-config.php
    sed -i "s/username_here/usu2008/" /var/www/html/wp-config.php
    sed -i "s/password_here/secret/" /var/www/html/wp-config.php
    sed -i "s/localhost/mysql2008/" /var/www/html/wp-config.php
fi

# Iniciar el servidor web de Apache
apache2-foreground
