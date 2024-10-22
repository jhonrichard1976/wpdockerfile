# Usar la imagen oficial de WordPress como base
FROM wordpress:latest

# Establecer las variables de entorno necesarias para la base de datos de WordPress
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

# Habilitar el módulo headers para gestionar los encabezados
RUN a2enmod headers

# Añadir la cabecera X-Frame-Options "SAMEORIGIN" para mejorar la seguridad
RUN echo 'Header always set X-Frame-Options "SAMEORIGIN"' >> /etc/apache2/conf-available/security.conf

# Añadir la restricción para xmlrpc.php en la configuración de Apache
RUN echo '<FilesMatch "xmlrpc\.php$">' >> /var/www/html/.htaccess \
    && echo '    Order deny,allow' >> /var/www/html/.htaccess \
    && echo '    Deny from all' >> /var/www/html/.htaccess \
    && echo '    Allow from 163.247.51.138' >> /var/www/html/.htaccess \
    && echo '</FilesMatch>' >> /var/www/html/.htaccess

# Instalar WP-CLI para administrar WordPress desde la línea de comandos
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Descargar e instalar WordPress en el directorio adecuado
WORKDIR /var/www/html
RUN wp core download --allow-root

# Cambiar los permisos de las carpetas necesarias para el usuario no root
# Asigna el dueño de los archivos a 'www-data' y ajusta los permisos
RUN chown -R www-data:www-data /var/www/html \
    && find /var/www/html/ -type d -exec chmod 755 {} \; \
    && find /var/www/html/ -type f -exec chmod 644 {} \;

# Instalar el plugin 'Stop User Enumeration' para mejorar la seguridad
RUN wp plugin install stop-user-enumeration --activate --allow-root --path=/var/www/html

# Deshabilitar la API REST para usuarios no autenticados
RUN echo "<?php
add_filter('rest_authentication_errors', function (\$result) {
    if (!empty(\$result)) {
        return \$result;
    }
    if (!is_user_logged_in()) {
        return new WP_Error('rest_not_logged_in', 'Debes estar autenticado para acceder a la API REST.', array('status' => 401));
    }
    return \$result;
});
?>" >> /var/www/html/wp-content/themes/twentytwentyone/functions.php

# Exponer el puerto 80 para acceso web
EXPOSE 80
