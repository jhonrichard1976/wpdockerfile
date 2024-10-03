# Usa la imagen oficial de WordPress como base
FROM wordpress:latest

# Opcionalmente, puedes configurar variables de entorno aquí o en tu docker-compose.yml
# ENV WORDPRESS_DB_HOST=mysql
# ENV WORDPRESS_DB_USER=root
# ENV WORDPRESS_DB_PASSWORD=root
# ENV WORDPRESS_DB_NAME=wordpress

# Si necesitas modificar algún archivo o hacer personalizaciones, puedes hacerlo aquí.
# Por ejemplo, modificar wp-config.php o agregar plugins.

# Por ejemplo, agregar una línea al wp-config.php para aumentar el límite de memoria:
RUN echo "define('WP_MEMORY_LIMIT', '256M');" >> /var/www/html/wp-config.php

# Exponer el puerto por donde correrá la aplicación
EXPOSE 80
