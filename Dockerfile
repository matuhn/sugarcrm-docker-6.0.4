FROM php:5.6-apache

ENV SUGARCRM https://github.com/matthewpoer/SugarCRM-Community-Edition/raw/master/OldFiles/SugarCRM%20Release%20Archive/SugarCRM%206.0%20GA/SugarCommunityEdition-6.0.4/SugarCE-6.0.4.zip
ENV WWW_FOLDER /var/www/html


RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y libcurl4-gnutls-dev libpng-dev unzip cron re2c python curl 

RUN docker-php-ext-install mysql curl gd zip mbstring
#	apt-get install -y php-mysql php5-imap php-curl php-gd curl unzip cron

WORKDIR /tmp

RUN curl -L -O "${SUGARCRM}" && \
	unzip SugarCE-6.0.4.zip && \
	rm -rf ${WWW_FOLDER}/* && \
	cp -R /tmp/SugarCE-Full-6.0.4/* ${WWW_FOLDER}/&& \
	chown -R www-data:www-data ${WWW_FOLDER}/* && \
	chown -R www-data:www-data ${WWW_FOLDER}

# RUN sed -i 's/^upload_max_filesize = 2M$/upload_max_filesize = 10M/' /usr/local/etc/php/php.ini

COPY docker-php-ext-filesize.ini /usr/local/etc/php/conf.d/docker-php-ext-filesize.ini

RUN apt-get update && apt-get install -y libc-client-dev libkrb5-dev && rm -r /var/lib/apt/lists/*
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
    docker-php-ext-install imap

ADD config_override.php.pyt /usr/local/src/config_override.php.pyt
ADD envtemplate.py /usr/local/bin/envtemplate.py
ADD init.sh /usr/local/bin/init.sh

RUN chmod u+x /usr/local/bin/init.sh

ADD crons.conf /root/crons.conf
RUN crontab /root/crons.conf

EXPOSE 80
ENTRYPOINT ["/usr/local/bin/init.sh"]
