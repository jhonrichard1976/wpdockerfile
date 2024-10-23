# Usa la imagen oficial de WordPress desde Docker Hub
FROM wordpress:latest

# Establece las variables de entorno necesarias para la conexión a la base de datos
ENV WORDPRESS_DB_HOST=mysql2008
ENV WORDPRESS_DB_NAME=wordpress2008
ENV WORDPRESS_DB_USER=usu2008
ENV WORDPRESS_DB_PASSWORD=secret

# Exponer el puerto 80 para WordPress
EXPOSE 80

# Establece el punto de entrada por defecto de la imagen oficial de WordPress
CMD ["apache2-foreground"]
