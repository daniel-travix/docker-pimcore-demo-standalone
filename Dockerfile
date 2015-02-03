FROM google/debian:wheezy
MAINTAINER pimcore GmbH <info@pimcore.com>

RUN apt-get update && \
 DEBIAN_FRONTEND=noninteractive apt-get -y upgrade && \
 DEBIAN_FRONTEND=noninteractive apt-get -y install wget sudo supervisor pwgen

ADD sources.list /tmp/sources.list
RUN cat /tmp/sources.list >> /etc/apt/sources.list 

RUN wget -O - http://www.dotdeb.org/dotdeb.gpg | apt-key add - 

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install \
 php5-fpm php5-cli php5-curl php5-dev php5-gd php5-imagick php5-imap \
 php5-intl php5-mcrypt php5-memcache php5-mysql php5-sqlite php5-redis \
 bzip2 unzip libxrender1 libfontconfig1 imagemagick \
 build-essential libssl-dev lynx autoconf libmagickwand-dev \
 pngnq pngcrush xvfb cabextract libfcgi0ldbl poppler-utils xfonts-75dpi \
 mysql-server-5.6 redis-server postfix

RUN apt-get -y -t wheezy-backports install libreoffice python-uno libreoffice-math

RUN apt-get -y install apache2-mpm-worker libapache2-mod-fastcgi
 
RUN a2enmod rewrite actions fastcgi alias
RUN a2dismod cgi autoindex
ADD vhost.conf /etc/apache2/sites-enabled/000-default

RUN rm -r /etc/php5/cli/php.ini && ln -s /etc/php5/fpm/php.ini /etc/php5/cli/php.ini
RUN mv /etc/php5/fpm/pool.d/www.conf /etc/php5/fpm/pool.d/www.conf.dist
ADD www-data.conf /etc/php5/fpm/pool.d/www-data.conf

RUN wget "http://downloads.sourceforge.net/project/wkhtmltopdf/0.12.2.1/wkhtmltox-0.12.2.1_linux-wheezy-amd64.deb?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fwkhtmltopdf%2Ffiles%2F0.12.2.1%2Fwkhtmltox-0.12.2.1_linux-wheezy-amd64.deb%2Fdownload%3Fuse_mirror%3Doptimate&ts=1422911314&use_mirror=heanet" -O wkhtmltopdf-0.12.deb && dpkg -i wkhtmltopdf-0.12.deb

ADD install-ghostscript.sh /tmp/install-ghostscript.sh
ADD install-ffmpeg.sh /tmp/install-ffmpeg.sh
ADD install-optimizers.sh /tmp/install-optimizers.sh
RUN chmod 755 /tmp/*.sh
RUN /tmp/install-ghostscript.sh
RUN /tmp/install-ffmpeg.sh 
RUN /tmp/install-optimizers.sh 

RUN wget https://www.pimcore.org/download/pimcore-latest.zip -O /var/www/pimcore.zip 
RUN cd /var/www && unzip pimcore.zip && rm pimcore.zip 

ADD start-apache.sh /start-apache.sh
ADD start-php-fpm.sh /start-php-fpm.sh
ADD run.sh /run.sh
RUN chmod 755 /*.sh
ADD supervisord-apache-fpm.conf /etc/supervisor/conf.d/supervisord-apache-fpm.conf

EXPOSE 80
CMD ["/run.sh"]
