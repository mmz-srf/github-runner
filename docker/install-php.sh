#!/bin/bash

: "${PHP_VERSION:=7.4}"

echo "deb https://packages.sury.org/php/ buster main" > /etc/apt/sources.list.d/sury.list
wget -qO - https://packages.sury.org/php/apt.gpg | sudo apt-key add -

apt update
apt install -y php${PHP_VERSION} \
               php${PHP_VERSION}-apcu \
               php${PHP_VERSION}-apcu-bc \
               php${PHP_VERSION}-gd \
               php${PHP_VERSION}-bz2 \
               php${PHP_VERSION}-ldap \
               php${PHP_VERSION}-bcmath \
               php${PHP_VERSION}-imagick \
               php${PHP_VERSION}-apcu \
               php${PHP_VERSION}-memcached \
               php${PHP_VERSION}-gearman \
               php${PHP_VERSION}-xdebug \
               php${PHP_VERSION}-apcu-bc \
               php${PHP_VERSION}-zip \
               php${PHP_VERSION}-xml \
               php${PHP_VERSION}-curl \
               php${PHP_VERSION}-mysqli \
               unzip \
               imagemagick

apt clean
