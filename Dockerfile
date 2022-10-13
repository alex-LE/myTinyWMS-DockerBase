FROM library/php:7.3-fpm

RUN set -e -x \
    && apt-get update \
    && apt-get -y upgrade ca-certificates \
    && apt-get install -y \
        apt-transport-https \
        nginx \
        wget nano unzip \
        zlib1g-dev zlib1g libmcrypt-dev libicu-dev \
        supervisor mariadb-client \
        libpcre3-dev \
        libc-client-dev libkrb5-dev \
        libpq-dev libzip-dev \
        libldap2-dev libxrender1 libxext6 \
        locales git gnupg \
        libfreetype6-dev libmcrypt-dev libjpeg-dev libpng-dev \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install -j$(nproc) zip intl bcmath imap iconv \
    && docker-php-ext-install pdo pdo_mysql \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-install ldap \
    && docker-php-ext-configure gd \
            --with-freetype-dir=/usr/include/freetype2 \
            --with-png-dir=/usr/include \
            --with-jpeg-dir=/usr/include \
    && docker-php-ext-install gd pcntl \
    && docker-php-ext-install mbstring \
    && docker-php-ext-enable opcache gd \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && sed -i '/^#.* de_DE.* /s/^#//' /etc/locale.gen \
    && locale-gen

# Install wkhtmltopdf
RUN set -e -x \
	&& wget "https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.stretch_amd64.deb" -q -O /tmp/wkhtmltox_0.12.6-1.stretch_amd64.deb \
	&& apt install -y /tmp/wkhtmltox_0.12.6-1.stretch_amd64.deb \
	&& rm -rf /tmp/wkhtmltox_0.12.6-1.stretch_amd64.deb

# Install nodejs and npm
RUN set -e -x \
    && curl -sL https://deb.nodesource.com/setup_14.x | bash - \
	&& apt-get update && apt install -y nodejs \
	&& apt-get install -y --allow-unauthenticated nodejs \
	&& npm update -g npm

# Install composer
RUN set -ex \
	&& curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer