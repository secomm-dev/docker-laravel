FROM centos:7.5.1804

MAINTAINER Soulblade "phuocvu@builtwithdigital.com"

# Setup system
RUN yum -y --setopt=tsflags=nodocs install httpd wget mysql vi crontabs unzip sudo nodejs \
           gcc gcc-c++ make openssl-devel libpng libpng-devel autogen libtool nasm \
 && yum install -y http://dl.iuscommunity.org/pub/ius/stable/CentOS/7/x86_64/ius-release-1.0-14.ius.centos7.noarch.rpm \
 && yum -y install php71u php71u-common php71u-gd php71u-phar php71u-xml php71u-cli php71u-mbstring \
           php71u-tokenizer php71u-openssl php71u-pdo php71u-pecl-imagick php71u-pecl-redis \
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
 && sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php.ini
# Config apache
COPY conf/httpd.conf /etc/httpd/conf/httpd.conf
RUN sed -i 's/LoadModule authn_anon_module/#LoadModule authn_anon_module/g' /etc/httpd/conf.modules.d/00-base.conf \
 && sed -i 's/LoadModule authn_dbm_module/#LoadModule authn_dbm_module/g' /etc/httpd/conf.modules.d/00-base.conf \
 && sed -i 's/LoadModule authz_dbm_module/#LoadModule authz_dbm_module/g' /etc/httpd/conf.modules.d/00-base.conf \ 
 && sed -i 's/LoadModule authz_groupfile_module/#LoadModule authz_groupfile_module/g' /etc/httpd/conf.modules.d/00-base.conf \
 && sed -i 's/LoadModule authz_owner_module/#LoadModule authz_owner_module/g' /etc/httpd/conf.modules.d/00-base.conf \ 
 && sed -i 's/LoadModule cache_module/#LoadModule cache_module/g' /etc/httpd/conf.modules.d/00-base.conf \
 && sed -i 's/LoadModule cache_disk_module/#LoadModule cache_disk_module/g' /etc/httpd/conf.modules.d/00-base.conf \ 
 && sed -i 's/LoadModule ext_filter_module/#LoadModule ext_filter_module/g' /etc/httpd/conf.modules.d/00-base.conf \ 
 && sed -i 's/LoadModule include_module/#LoadModule include_module/g' /etc/httpd/conf.modules.d/00-base.conf \
 && sed -i 's/LoadModule info_module/#LoadModule info_module/g' /etc/httpd/conf.modules.d/00-base.conf \
 && sed -i 's/LoadModule logio_module/#LoadModule logio_module/g' /etc/httpd/conf.modules.d/00-base.conf \
 && sed -i 's/LoadModule status_module/#LoadModule status_module/g' /etc/httpd/conf.modules.d/00-base.conf \
 && sed -i 's/LoadModule substitute_module/#LoadModule substitute_module/g' /etc/httpd/conf.modules.d/00-base.conf \
 && sed -i 's/LoadModule userdir_module/#LoadModule userdir_module/g' /etc/httpd/conf.modules.d/00-base.conf \
 && sed -i 's/LoadModule vhost_alias_module/#LoadModule vhost_alias_module/g' /etc/httpd/conf.modules.d/00-base.conf \
 && sed -i 's/LoadModule proxy_ajp_module/#LoadModule proxy_ajp_module/g' /etc/httpd/conf.modules.d/00-proxy.conf \
 && sed -i 's/LoadModule proxy_balancer_module/#LoadModule proxy_balancer_module/g' /etc/httpd/conf.modules.d/00-proxy.conf \
 && sed -i 's/LoadModule proxy_connect_module/#LoadModule proxy_connect_module/g' /etc/httpd/conf.modules.d/00-proxy.conf \
 && sed -i 's/LoadModule proxy_ftp_module/#LoadModule proxy_ftp_module/g' /etc/httpd/conf.modules.d/00-proxy.conf \
 && sed -i 's/LoadModule proxy_http_module/#LoadModule proxy_http_module/g' /etc/httpd/conf.modules.d/00-proxy.conf \

WORKDIR /var/www/html

# Simple startup script to avoid some issues observed with container restart
ADD conf/run-httpd.sh /run-httpd.sh
RUN chmod -v +x /run-httpd.sh

CMD ["/run-httpd.sh", "/usr/sbin/crond"]

