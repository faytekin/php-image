ARG PHP_VERSION=8.2.4
ARG DEBIAN_VERSION=bullseye

FROM php:${PHP_VERSION}-${DEBIAN_VERSION}

RUN APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 \
    && apt-get update && env ACCEPT_EULA=Y apt-get install -y --no-install-recommends \
        gnupg2 \
        git \
        bash \
        procps \
    && rm -rf /var/lib/apt/lists/*

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions && sync && \
    install-php-extensions \
        bcmath \
        gd \
        exif \
        xsl \
        zip \
        intl \
        pdo_mysql \
        mbstring \
        redis \
        mcrypt \
        imagick \
        openswoole \
        pcntl \
        opcache \
        pcov \
        @composer \
        # just install xdebug (not enable it) 
        && IPE_DONT_ENABLE=1 install-php-extensions xdebug

RUN cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini \
    && sed -i 's,^memory_limit =.*$,memory_limit = -1,' /usr/local/etc/php/php.ini

WORKDIR /var/www/html

EXPOSE 80
