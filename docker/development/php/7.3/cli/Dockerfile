FROM php:7.3-cli

LABEL maintainer="Pavel A. Petrov <papahelmsman@gmail.com>"

ARG APCU_VERSION=5.1.11

RUN apt-get update && apt-get install -y git zip unzip libzip-dev zlib1g-dev libpq-dev git-core libmcrypt-dev \
    libfcgi0ldbl gnupg libfreetype6-dev libjpeg62-turbo-dev libpng-dev libicu-dev wget

RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo_pgsql \
    && docker-php-ext-install opcache \
    && docker-php-ext-install intl \
    && docker-php-ext-install mbstring

RUN pecl install apcu-${APCU_VERSION} \
    && docker-php-ext-enable apcu

RUN pecl install -o -f redis \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable redis

RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

COPY xdebug.ini /usr/local/etc/php/conf.d/
COPY symfony.ini /usr/local/etc/php/conf.d/

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/bin --filename=composer --quiet

ENV COMPOSER_ALLOW_SUPERUSER 1

RUN echo 'alias sf="php bin/console"' >> ~/.bashrc

WORKDIR /app
