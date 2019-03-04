FROM centos:7.5.1804

MAINTAINER Soulblade "phuocvu@builtwithdigital.com"

# Setup system
RUN yum -y --setopt=tsflags=nodocs install httpd wget mysql vi crontabs unzip sudo nodejs \
           gcc gcc-c++ make openssl-devel libpng libpng-devel autogen libtool nasm mod_ssl \
 && yum install -y http://dl.iuscommunity.org/pub/ius/stable/CentOS/7/x86_64/ius-release-1.0-14.ius.centos7.noarch.rpm \
 && yum -y install php71u php71u-common php71u-gd php71u-phar php71u-xml php71u-cli php71u-mbstring php71u-mysqlnd \
           php71u-json php71u-tokenizer php71u-openssl php71u-pdo php71u-pecl-imagick php71u-pecl-redis \
# Clean CentOS 7
 && yum clean all && rm -rf /var/cache/yum/* \
# Create sudo user
 && adduser -d /home/secomm secomm \
 && usermod -aG root,apache secomm \
 && echo "secomm      ALL=(ALL)       ALL" >> /etc/sudoers \
# Install Magerun
 && wget https://files.magerun.net/n98-magerun.phar && chmod +x ./n98-magerun.phar && mv ./n98-magerun.phar /usr/bin/ \
# Install composer
 && wget https://getcomposer.org/composer.phar && chmod +x composer.phar && mv composer.phar /usr/bin/composer \
# Config PHP
 && sed -i 's/memory_limit = 128M/memory_limit = 512M/g' /etc/php.ini \
 && sed -i 's/post_max_size = 8M/post_max_size = 256M/g' /etc/php.ini \
 && sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 256M/g' /etc/php.ini \
 && sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php.ini \
 && sed -i 's/IncludeOptional conf\.d\/\*\.conf/IncludeOptional conf\.d\/000\-default\.conf/g' /etc/httpd/conf/httpd.conf
# Config apache
COPY conf/httpd.conf /etc/httpd/conf/httpd.conf
RUN echo 'extension=pdo_mysql.so' >> /etc/php.d/20-pdo.ini

WORKDIR /var/www/html

# Simple startup script to avoid some issues observed with container restart
ADD conf/run-httpd.sh /run-httpd.sh
RUN chmod -v +x /run-httpd.sh

CMD ["/run-httpd.sh", "/usr/sbin/crond"]
