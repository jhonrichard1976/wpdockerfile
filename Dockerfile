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

# Bloquear el acceso a xmlrpc.php en la configuración de Apache
RUN echo '<FilesMatch "xmlrpc\.php$">\n\
    Order deny,allow\n\
    Deny from all\n\
</FilesMatch>' >> /etc/apache2/conf-available/security.conf

# Bloquear el acceso a wp-cron.php en la configuración de Apache
RUN echo '<FilesMatch "wp-cron\.php$">\n\
    Order deny,allow\n\
    Deny from all\n\
</FilesMatch>' >> /etc/apache2/conf-available/security.conf

# Habilitar la configuración de seguridad en Apache
RUN a2enconf security

# Configuración de CORS en Apache esta opcion se uso para quitar o mitigar  TRACE
RUN echo '<IfModule mod_headers.c>\n\
    Header set Access-Control-Allow-Origin "*"\n\
    Header set Access-Control-Allow-Methods "GET, POST, OPTIONS"\n\
    Header set Access-Control-Allow-Headers "Content-Type, Authorization"\n\
</IfModule>' \
>> /etc/apache2/conf-available/cors.conf

# Habilita el módulo headers y la configuración de CORS
RUN a2enconf cors

# Crear la estructura de directorios necesaria para el tema Divi
RUN mkdir -p /var/www/html/wp-content/themes/Divi/js

# Descargar una versión segura de Underscore.js y reemplazar la versión vulnerable
RUN curl -o /tmp/underscore.min.js https://cdnjs.cloudflare.com/ajax/libs/underscore.js/1.13.6/underscore-min.js \
    && cp /tmp/underscore.min.js /var/www/html/wp-content/themes/Divi/js/custom.js

# Copia el contenido de WordPress en el directorio de Apache
COPY . /var/www/html

# Cambiar los permisos de las carpetas necesarias para el usuario no root
RUN chown -R www-data:www-data /var/www/html/wp-content \
    && chmod -R 755 /var/www/html/wp-content

# Comando por defecto
CMD ["apache2-foreground"]
