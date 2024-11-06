# Usar la imagen oficial de WordPress
FROM wordpress:latest

# Establecer las variables de entorno necesarias
ENV WORDPRESS_DB_HOST=mysql2008 \
    WORDPRESS_DB_USER=usu2008 \
    WORDPRESS_DB_PASSWORD=secret \
    WORDPRESS_DB_NAME=wordpress2008

# Aumentar el límite de memoria de PHP y otros parámetros relacionados con la carga de archivos
RUN echo "memory_limit = 256M" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "upload_max_filesize = 3G" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "post_max_size = 3G" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "max_execution_time = 300" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "max_input_time = 300" >> /usr/local/etc/php/conf.d/uploads.ini

# Ocultar la versión de PHP
RUN echo "expose_php = Off" >> /usr/local/etc/php/conf.d/security.ini

# Ocultar la versión de Apache
RUN echo "ServerTokens Prod" >> /etc/apache2/conf-available/security.conf \
    && echo "ServerSignature Off" >> /etc/apache2/conf-available/security.conf

# Habilita los módulos necesarios en Apache
RUN a2enmod rewrite headers

# Añadir la cabecera HTTP Strict Transport Security (HSTS)
RUN echo 'Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"' >> /etc/apache2/conf-available/security.conf

# Añadir la cabecera X-Frame-Options: SAMEORIGIN
RUN echo 'Header always set X-Frame-Options "SAMEORIGIN"' >> /etc/apache2/conf-available/security.conf

# Añadir la restricción para xmlrpc.php en la configuración de Apache
RUN echo '<FilesMatch "xmlrpc\.php$">\n\
    Order deny,allow\n\
    Deny from all\n\
    Allow from 163.247.51.138\n\
</FilesMatch>' >> /etc/apache2/conf-available/security.conf

# Configuración de CORS: Permitir solo solicitudes desde el dominio especificado
RUN echo '<IfModule mod_headers.c>\n\
    Header set Access-Control-Allow-Origin "https://ssantofagastanuevo.minsal.cl"\n\
    Header set Access-Control-Allow-Methods "GET, POST, OPTIONS"\n\
    Header set Access-Control-Allow-Headers "Authorization, X-Requested-With"\n\
</IfModule>' >> /etc/apache2/conf-available/cors.conf

# Habilitar la configuración de seguridad y CORS en Apache
RUN a2enconf security \
    && a2enconf cors

# Instalar Fail2Ban
RUN apt-get update && apt-get install -y fail2ban && rm -rf /var/lib/apt/lists/*

# Configuración de Fail2Ban para WordPress
RUN echo '[wordpress]\n\
enabled = true\n\
filter = wordpress\n\
logpath = /var/log/apache2/access.log\n\
maxretry = 5\n\
bantime = 600\n\
findtime = 600\n\
action = iptables[name=wordpress, port=http, protocol=tcp]' > /etc/fail2ban/jail.d/wordpress.conf

# Crear el filtro de Fail2Ban para WordPress
RUN echo '[Definition]\n\
failregex = <HOST>.*POST /wp-login.php.* 200\n\
ignoreregex =' > /etc/fail2ban/filter.d/wordpress.conf

# Cambiar los permisos de las carpetas necesarias para el usuario no root
RUN chown -R www-data:www-data /var/www/html/wp-content \
    && chmod -R 755 /var/www/html/wp-content

# Agregar el código para deshabilitar la API REST en functions.php
RUN echo "<?php function completely_disable_rest_api(\$access) { return new WP_Error('', __('','your-text-domain'), array('status' => rest_authorization_required_code())); } add_filter('rest_authentication_errors', 'completely_disable_rest_api');" >> /var/www/html/ssantofagastanuevo/wp-content/themes/functions.php

# Iniciar Fail2Ban y Apache en un solo comando
CMD service fail2ban start && apache2-foreground
