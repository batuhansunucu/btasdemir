FROM php:7.4-fpm

USER root

WORKDIR /var/www
# Install dependencies
RUN apt-get update \
	&& apt-get install -y libmagickwand-dev --no-install-recommends \
    gnupg2 \
    syslog-ng \
	build-essential \
	procps \
	openssl \
	nginx \
	libnginx-mod-http-perl \
	libfreetype6-dev \
	libjpeg-dev \
	libpng-dev libwebp-dev zlib1g-dev \
	libzip-dev \
	gcc \
	g++ \
	make \
	vim \
	unzip \
	curl \
	git \
	jpegoptim \
	optipng \
	pngquant \
	gifsicle \
	locales \
	libonig-dev \
	libgmp-dev \
	supervisor \
    npm \
    nodejs \
    libjpeg62-turbo-dev \
	&& docker-php-ext-configure \
	gd --with-freetype --with-jpeg \
	&& docker-php-ext-install -j$(nproc) \
	gd \
	gmp \
	bcmath \
	exif \
	pdo_mysql mbstring \
	pdo \
	zip \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && apt-get install -y libicu-dev \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl \
	&& docker-php-ext-enable \
	opcache \
	&& apt-get autoclean -y \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /tmp/pear/ \
RUN apt-get update && \
    apt-get install -y curl gnupg && \
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - && \
    apt-get update -y && \
    apt-get install google-cloud-sdk -y \
RUN apk add --no-cache nginx wget

RUN mkdir -p /run/nginx

COPY docker/nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /app
COPY . /app

RUN sh -c "wget http://getcomposer.org/composer.phar && chmod a+x composer.phar && mv composer.phar /usr/local/bin/composer"
RUN cd /app && \
    /usr/local/bin/composer install --no-dev

RUN chown -R www-data: /app

CMD sh /app/docker/startup.sh
