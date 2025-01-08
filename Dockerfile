# Usa la imagen oficial de WordPress desde Docker Hub
FROM docker.io/rychy499/wordpress_sinres:6.6.2

# Declara el volumen para persistencia
VOLUME ["/var/www/html"]

# Exponer el puerto 80 para WordPress
EXPOSE 80

# Establece el punto de entrada por defecto de la imagen oficial de WordPress
CMD ["apache2-foreground"]
