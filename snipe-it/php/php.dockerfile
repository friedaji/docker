FROM php:7.1-apache

#https://snipe-it.readme.io/docs/requirements

RUN apt-get update && apt-get install -y \
    apt-utils \
    zlib1g-dev \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-source extract \
    && docker-php-ext-install pdo pdo_mysql \
    && docker-php-ext-install phpzip \
    && docker-php-ext-install opcache \
    && docker-php-ext-install mbstring \
    && docker-php-ext-install ldap \
    && docker-php-ext-install fileinfo \
    && docker-php-ext-install tokenizer \
    && docker-php-ext-install curl

RUN pecl install apcu
RUN echo "extension=apcu.so" > /usr/local/etc/php/conf.d/apcu.ini
RUN a2enmod rewrite