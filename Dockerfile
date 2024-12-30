# Usa la imagen oficial de WordPress desde Docker Hub
FROM docker.io/wordpress:latest

# Declara el volumen para persistencia
VOLUME ["/var/www/html"]
# Ocultar la versión de PHP
RUN echo "expose_php = Off" >> /usr/local/etc/php/conf.d/security.ini

# Ocultar la versión de Apache
RUN echo "ServerTokens Prod" >> /etc/apache2/conf-available/security.conf \
    && echo "ServerSignature Off" >> /etc/apache2/conf-available/security.conf


# Exponer el puerto 80 para WordPress
EXPOSE 8080

# Establece el punto de entrada por defecto de la imagen oficial de WordPress
CMD ["apache2-foreground"]
