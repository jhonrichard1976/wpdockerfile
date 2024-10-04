# Usar la imagen desde Quay
FROM wordpress:6.6.2

# Establecer las variables de entorno necesarias
ENV WORDPRESS_DB_HOST=mysql2008 \
    WORDPRESS_DB_USER=usu2008 \
    WORDPRESS_DB_PASSWORD=secret \
    WORDPRESS_DB_NAME=wordpress2008

# Aumentar el límite de memoria de WordPress (opcional)
RUN echo "define('WP_MEMORY_LIMIT', '256M');" >> /usr/src/wordpress/wp-config-sample.php

# Cambiar los permisos de las carpetas necesarias para el usuario no root
RUN chown -R www-data:www-data /var/www/html/wp-content \
    && chmod -R 755 /var/www/html/wp-content

# Agregar un script de inicio para asegurar que se modifiquen los archivos necesarios al inicio
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Ejecutar el script al iniciar
CMD ["/usr/local/bin/start.sh"]
