# --- Dockerfile ---
# Use PHP 8.3 with Apache as base image
FROM php:8.3-apache

# Set environment variable for Moodle version (can be overridden at build time)
ARG MOODLE_BRANCH=MOODLE_405_STABLE

# Install dependencies and PHP extensions
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        unzip git curl libzip-dev libjpeg-dev libpng-dev \
        libfreetype6-dev libicu-dev libxml2-dev libpq-dev \
        libonig-dev && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install mysqli zip gd intl soap exif pgsql pdo_pgsql opcache && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Clone Moodle source (use ARG to select branch)
RUN git clone https://github.com/moodle/moodle.git /tmp/moodle && \
    cd /tmp/moodle && \
    git checkout $MOODLE_BRANCH && \
    cp -rf /tmp/moodle/* /var/www/html/ && \
    rm -rf /tmp/moodle

# Set up PHP configuration for Moodle
RUN echo "max_input_vars=5000" >> /usr/local/etc/php/conf.d/moodle.ini && \
    echo "opcache.enable=1" >> /usr/local/etc/php/conf.d/opcache.ini && \
    echo "opcache.memory_consumption=128" >> /usr/local/etc/php/conf.d/opcache.ini && \
    echo "opcache.max_accelerated_files=10000" >> /usr/local/etc/php/conf.d/opcache.ini && \
    echo "opcache.validate_timestamps=1" >> /usr/local/etc/php/conf.d/opcache.ini

# Moodledata directory for file storage
RUN mkdir -p /var/www/moodledata && \
    chown -R www-data:www-data /var/www && \
    chmod -R 755 /var/www

# Set working directory and expose port
WORKDIR /var/www/html
EXPOSE 80

# Run as www-data user for security
USER www-data
