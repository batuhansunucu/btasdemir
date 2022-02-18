FROM php:7.4-fpm-alpine

RUN apk add --no-cache nginx wget

RUN mkdir -p /run/nginx

COPY docker/nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /app
COPY . /app

RUN sh -c "wget http://getcomposer.org/composer.phar && chmod a+x composer.phar && mv composer.phar /usr/local/bin/composer"
RUN cd /app && \
    /usr/local/bin/composer install --no-dev

RUN chown -R www-data: /app

ENV PHP_CONFIG_TEMPLATE=/laravel/storage

RUN mkdir -p $PHP_CONFIG_TEMPLATE \
	&& chown -R www-data.www-data \
       $PHP_CONFIG_TEMPLATE \
    && chmod 755 $PHP_CONFIG_TEMPLATE
    
CMD sh /app/docker/startup.sh
