FROM php:8.0.2-fpm-buster

ENV php_conf /usr/local/etc/php-fpm.conf
ENV fpm_conf /usr/local/etc/php-fpm.d/www.conf
ENV php_vars /usr/local/etc/php/conf.d/docker-vars.ini

RUN APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 \
    && apt-get update && apt-get install -y --no-install-recommends \
        curl \
        gnupg2 \
        ca-certificates \
        lsb-release \
        bash \
        libmcrypt-dev \
        libpng-dev \
        wget \
        git \
        supervisor \
        libxslt-dev \
        libjpeg-dev \
        libpq-dev \
        libmemcached-dev \
        libgeos-dev \
        libzip-dev \
        libonig-dev \
        unzip \
        openssh-client \
        mariadb-client \
        libbz2-dev \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure \
        gd \
        --with-jpeg

RUN docker-php-ext-install bcmath \
    pdo \
    pdo_mysql \
    iconv \
    mysqli \
    mbstring \
    gd \
    exif \
    xsl \
    json \
    soap \
    dom \
    zip \
    opcache \
    intl \
    bz2 \
    pcntl

RUN pecl install mcrypt-1.0.3 \
    && docker-php-ext-enable mcrypt

# tweak php-fpm config
RUN echo "cgi.fix_pathinfo=1" > ${php_vars} \
        && echo "upload_max_filesize = 100M"  >> ${php_vars} \
        && echo "post_max_size = 100M"  >> ${php_vars} \
        && echo "variables_order = \"EGPCS\""  >> ${php_vars} \
        && echo "memory_limit = -1"  >> ${php_vars} \
    && sed -i \
        -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" \
        -e "s/pm.max_children = 5/pm.max_children = 4/g" \
        -e "s/pm.start_servers = 2/pm.start_servers = 3/g" \
        -e "s/pm.min_spare_servers = 1/pm.min_spare_servers = 2/g" \
        -e "s/pm.max_spare_servers = 3/pm.max_spare_servers = 4/g" \
        -e "s/;pm.max_requests = 500/pm.max_requests = 200/g" \
        -e "s/user = www-data/user = nginx/g" \
        -e "s/group = www-data/group = nginx/g" \
        -e "s/;listen.mode = 0660/listen.mode = 0666/g" \
        -e "s/;listen.owner = www-data/listen.owner = nginx/g" \
        -e "s/;listen.group = www-data/listen.group = nginx/g" \
        -e "s/^;clear_env = no$/clear_env = no/" \
        ${fpm_conf}

# Install php composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

ENV WEBROOT=/var/www/html

EXPOSE 80
