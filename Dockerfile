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

# Habilitar el módulo headers para gestionar los encabezados
RUN a2enmod headers

# Añadir la cabecera X-Frame-Options: SAMEORIGIN
RUN echo 'Header always set X-Frame-Options "SAMEORIGIN"' >> /etc/apache2/conf-available/security.conf

# Añadir la restricción para xmlrpc.php en la configuración de Apache
RUN echo '<FilesMatch "xmlrpc\.php$">\n\
    Order deny,allow\n\
    Deny from all\n\
    Allow from 163.247.51.138\n\
</FilesMatch>' >> /etc/apache2/conf-available/security.conf

# Habilitar la configuración de seguridad en Apache
RUN a2enconf security

# Instalar WP-CLI para administrar plugins
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Instalar el plugin Stop User Enumeration y activarlo
RUN wp plugin install stop-user-enumeration --activate --allow-root

# Deshabilitar la API REST para usuarios no autenticados agregando un filtro en wp-config.php
RUN echo "add_filter('rest_authentication_errors', function(\$result) {" >> /usr/src/wordpress/wp-config.php \
    && echo "if (!empty(\$result)) { return \$result; }" >> /usr/src/wordpress/wp-config.php \
    && echo "if (!is_user_logged_in()) { return new WP_Error('rest_cannot_access', 'No tienes permisos para acceder a esta API.', array('status' => 401)); }" >> /usr/src/wordpress/wp-config.php \
    && echo "return \$result; });" >> /usr/src/wordpress/wp-config.php

# Cambiar los permisos de las carpetas necesarias para el usuario no root
RUN chown -R www-data:www-data /var/www/html/wp-content \
    && chmod -R 755 /var/www/html/wp-content

# Comando por defecto
CMD ["apache2-foreground"]
