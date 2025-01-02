# Usa la imagen oficial de WordPress desde Docker Hub
FROM docker.io/wordpress:latest

# Declara el volumen para persistencia
VOLUME ["/var/www/html"]

# Exponer el puerto 80 para WordPress
EXPOSE 8080

# Establece el punto de entrada por defecto de la imagen oficial de WordPress
CMD ["apache2-foreground"]
