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

# Añadir la restricción para xmlrpc.php en la configuración de Apache.
RUN echo '<FilesMatch "xmlrpc\.php$">\n\
    Order deny,allow\n\
    Deny from all\n\
    Allow from 163.247.51.138\n\
</FilesMatch>' >> /etc/apache2/conf-available/security.conf

# Añadir la restricción para wp-cron.php en la configuración de Apache
RUN echo '<FilesMatch "wp-cron\.php$">\n\
    Order deny,allow\n\
    Deny from all\n\
    Allow from 163.247.51.138\n\
</FilesMatch>' >> /etc/apache2/conf-available/security.conf

# Habilitar la configuración de seguridad en Apache
RUN a2enconf security

# Cambiar los permisos de las carpetas necesarias para el usuario no root
RUN chown -R www-data:www-data /var/www/html/wp-content \
    && chmod -R 755 /var/www/html/wp-content

# Comando por defecto
CMD ["apache2-foreground"]
