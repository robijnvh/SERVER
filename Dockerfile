# INSTALL  DEBIAN:BUSTER
FROM	debian:buster

# INSTALL UPDATE
RUN		apt-get update
RUN		apt-get upgrade -y

# DOWNLOAD WGET
RUN		apt-get -y install wget sendmail

# NGINX
RUN		apt-get -y install nginx 
COPY 	./srcs/nginx.config /etc/nginx/sites-available/localhost

# SSL 
WORKDIR /var/cert
COPY 	./srcs/certificate.pem /var/cert/
COPY 	./srcs/key.pem /var/cert/

# SETUP MENU_WEBSITE
RUN 	mkdir -p /var/www/localhost/wordpress/menu_website
COPY 	/srcs/index.html /var/www/localhost/wordpress/menu_website

# SYMLINK
RUN 	ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/localhost 

# SETUP MSQL BASICS
RUN 	apt-get -y install mariadb-server
RUN 	apt-get -y install mariadb-server
RUN 	service mysql start; \
    	echo "CREATE DATABASE sick_database;" | mysql -u root; \
    	echo "GRANT ALL PRIVILEGES ON *.* TO 'rvan-hou'@'localhost' IDENTIFIED BY 'hoeishetdan123';" | mysql -u root; \
    	echo "FLUSH PRIVILEGES" | mysql -u root

## INSTALL PHPMYADMIN
WORKDIR /var/www/localhost/wordpress/
RUN		apt-get -y install php7.3-fpm php-common php-mysql php-mbstring php-cli
RUN		wget https://files.phpmyadmin.net/phpMyAdmin/4.9.2/phpMyAdmin-4.9.2-english.tar.gz
RUN		tar -xzvf phpMyAdmin-4.9.2-english.tar.gz
RUN 	mv phpMyAdmin-4.9.2-english phpmyadmin
COPY 	./srcs/config.inc.php /var/www/localhost/wordpress/phpmyadmin
RUN 	chmod -R 755 phpmyadmin

## INSTALL WORDPRESS
RUN		wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN 	chmod +x wp-cli.phar
RUN 	mv wp-cli.phar /usr/local/bin/wp
WORKDIR /var/www/localhost/wordpress
RUN		service mysql start &&\
 	 	wp core download --allow-root &&\
		wp config create --dbhost=localhost --dbname=sick_database --dbuser=rvan-hou --dbpass=hoeishetdan123 --allow-root &&\
		wp core install --url=localhost --title="WHAT's UP?" --admin_name=rvan-hou_admin --admin_password=hoeishetdan123 --admin_email=nee@ja.com --allow-root &&\
		chmod 644 wp-config.php &&\
		wp theme install https://downloads.wordpress.org/theme/blossom-travel.1.0.4.zip --allow-root &&\
    	wp theme activate blossom-travel --allow-root

#RUN PROGRAM
COPY ./srcs/program.sh /root/
CMD bash /root/program.sh

EXPOSE 80
EXPOSE 443