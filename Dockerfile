# Usar la imagen base de WordPress
FROM wordpress:latest

# Establecer las variables de entorno necesarias
ENV WORDPRESS_DB_HOST=mysql2008
ENV WORDPRESS_DB_USER=usu2008
ENV WORDPRESS_DB_PASSWORD=secret
ENV WORDPRESS_DB_NAME=wordpress2008

# Aumentar el límite de memoria de WordPress
RUN echo "define('WP_MEMORY_LIMIT', '256M');" >> /usr/src/wordpress/wp-config.php

# Comando por defecto
CMD ["apache2-foreground"]
