# Usar la imagen oficial de WordPress
FROM wordpress:latest

# Establecer las variables de entorno necesarias
ENV WORDPRESS_DB_HOST=mysql2008 \
    WORDPRESS_DB_USER=usu2008 \
    WORDPRESS_DB_PASSWORD=secret \
    WORDPRESS_DB_NAME=wordpress2008

# Aumentar el límite de memoria de PHP
RUN echo "memory_limit = 256M" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "upload_max_filesize = 128M" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "post_max_size = 128M" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "max_execution_time = 300" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "max_input_time = 300" >> /usr/local/etc/php/conf.d/uploads.ini

# Ocultar la versión de Apache
RUN echo "ServerTokens Prod" >> /etc/apache2/conf-available/security.conf \
    && echo "ServerSignature Off" >> /etc/apache2/conf-available/security.conf

# Habilitar el módulo headers para gestionar los encabezados
RUN a2enmod headers

# Añadir la cabecera X-Frame-Options: SAMEORIGIN
RUN echo 'Header always set X-Frame-Options "SAMEORIGIN"' >> /etc/apache2/conf-available/security.conf

# Crear el archivo .htpasswd con el usuario y la contraseña
RUN apt-get update && apt-get install -y apache2-utils \
    && htpasswd -bc /var/www/html/.htpasswd usuario secreto

# Configurar la protección de wp-login.php
RUN echo '<Files wp-login.php>\n\
   AuthUserFile /var/www/html/.htpasswd\n\
   AuthName "Acceso privado bajo llave"\n\
   AuthType Basic\n\
   require user miusuariosecreto\n\
</Files>' > /var/www/html/.htaccess

# Cambiar los permisos de las carpetas necesarias para el usuario no root
RUN chown -R www-data:www-data /var/www/html/wp-content \
    && chmod -R 755 /var/www/html/wp-content

# Comando por defecto
CMD ["apache2-foreground"]
