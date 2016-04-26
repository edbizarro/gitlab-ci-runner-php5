FROM php:5.6
MAINTAINER Eduardo Bizarro <edbizarro@gmail.com>
RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y \
    libbz2-dev \
    libcurl4-openssl-dev \
    libmcrypt-dev \
    php-pear \
    curl \
    git \
    unzip \
    zlib1g-dev \
    libxml2-dev \
  && rm -r /var/lib/apt/lists/*

# PHP Extensions
RUN docker-php-ext-install mcrypt zip xml mbstring curl json pdo_mysql tokenizer
  
  # Run xdebug installation.
RUN curl -L https://xdebug.org/files/xdebug-2.4.0rc4.tgz >> /usr/src/php/ext/xdebug.tgz && \
    tar -xf /usr/src/php/ext/xdebug.tgz -C /usr/src/php/ext/ && \
    rm /usr/src/php/ext/xdebug.tgz && \
    docker-php-ext-install xdebug-2.4.0RC4 && \
    docker-php-ext-install pcntl && \
    php -m
  
# Memory Limit
RUN echo "memory_limit=-1" > $PHP_INI_DIR/conf.d/memory-limit.ini

# Time Zone
#RUN echo "date.timezone=Europe/Amsterdam" > $PHP_INI_DIR/conf.d/date_timezone.ini

VOLUME /root/composer

# Environmental Variables
ENV COMPOSER_HOME /root/composer

# Display PHP version
RUN php --version

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
    
# Goto temporary directory.
WORKDIR /tmp

# Run composer and phpunit installation.
RUN composer selfupdate && \
    composer global require "hirak/prestissimo:^0.1" --no-interaction && \
    composer require "phpunit/phpunit:^4.8" --prefer-source --no-interaction && \
    ln -s /tmp/vendor/bin/phpunit /usr/local/bin/phpunit

RUN composer --version

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
