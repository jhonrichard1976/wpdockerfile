# Usa la imagen oficial de WordPress desde Docker Hub
FROM docker.io/rychy499/wordpress_sinres:6.6.2

# Ocultar la versión de PHP
RUN echo "expose_php = Off" >> /usr/local/etc/php/conf.d/security.ini

# Declara el volumen para persistencia
VOLUME ["/var/www/html"]

# Exponer el puerto 80 para WordPress
EXPOSE 8080

# Establece el punto de entrada por defecto de la imagen oficial de WordPress
CMD ["apache2-foreground"]
