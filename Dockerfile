FROM wordpress:php8.2-fpm

# Cambiar al usuario root para instalar paquetes
USER root

# Instalar Nginx
RUN apt-get update && apt-get install -y nginx && apt-get clean

# Copiar el archivo de configuración de Nginx
COPY default.conf /etc/nginx/conf.d/

# Crear los directorios necesarios y ajustar permisos
RUN mkdir -p /var/www/html /var/run/nginx && \
    chmod -R 755 /var/www/html /var/run/nginx

# Exponer los puertos necesarios
EXPOSE 80

# Definir el comando de inicio para Nginx y PHP-FPM
CMD service nginx start && php-fpm -F
