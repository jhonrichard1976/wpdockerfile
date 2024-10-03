# Usa la imagen oficial de WordPress como base
FROM wordpress:latest

# Configura las variables de entorno para la base de datos
ENV WORDPRESS_DB_HOST=mysql2008 \
    WORDPRESS_DB_USER=usu2008 \
    WORDPRESS_DB_PASSWORD=secret \
    WORDPRESS_DB_NAME=wordpress2008

# Opcionalmente, puedes modificar wp-config.php para aumentar el límite de memoria
RUN echo "define('WP_MEMORY_LIMIT', '256M');" >> /var/www/html/wp-config.php

# Exponer el puerto por donde correrá la aplicación
EXPOSE 80
