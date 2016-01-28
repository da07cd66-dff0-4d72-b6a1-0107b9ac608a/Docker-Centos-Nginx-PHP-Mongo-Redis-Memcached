#vim:set ft=dockerfile:
FROM centos:latest

MAINTAINER oBlank <dyh1919@gmail.com>

# Add the ngix and PHP dependent repository
ADD ./files/nginx.repo /etc/yum.repos.d/nginx.repo

# Installing nginx
RUN yum -y install nginx perl

# Installing PHP
RUN yum -y --enablerepo=remi,remi-php56 install nginx \
        php-fpm php-mysql php-mcrypt php-curl php-cli php-gd php-pgsql php-pdo \
        php-common php-json php-pecl-redis php-pecl-memcache php-pecl-memcached nginx python-pip \
        vim telnet git php-mbstring php-pecl-xdebug php-soap php-yaml && \
        yum clean all


# Installing supervisor
RUN yum install -y python-setuptools
RUN easy_install pip
RUN pip install supervisor supervisor-stdout


# Supervisor config
#RUN /usr/bin/pip install supervisor supervisor-stdout

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

ADD ./files/conf.d /etc/nginx/conf.d
ADD ./files/nginx.conf /etc/nginx/nginx.conf
ADD ./files/php.ini /etc/php.ini
ADD ./files/php-fpm.conf /etc/php-fpm.conf
ADD ./files/php-fpm.d /etc/php-fpm.d
ADD ./files/php.d/15-xdebug.ini /etc/php.d/15-xdebug.ini
ADD ./files/supervisord.conf /etc/supervisord.conf

# Adding the default file
ADD ./files/index.php /data/www/htdocs/index.php

# Volumes
VOLUME /var/log
VOLUME /var/lib/php/session
VOLUME /data/www/htdocs/


# Install MongoDB
RUN echo -e "[mongodb]\nname=MongoDB Repository\nbaseurl=https://repo.mongodb.org/yum/redhat/7/mongodb-org/3.2/`uname -m`/\ngpgcheck=0\nenabled=1" > /etc/
yum.repos.d/mongodb.repo
RUN yum install -y mongodb-org
#RUN yum -y install mongodb-server; yum clean all
RUN mkdir -p /data/db
RUN echo 'smallfiles = true' >> /etc/mongod.conf # make journal small
#RUN /etc/init.d/mongod start && /etc/init.d/mongod stop

# memcached (1.4.4-3.el6)
RUN echo "NETWORKING=yes" >/etc/sysconfig/network
RUN yum -y install memcached
#RUN /etc/init.d/memcached start && /etc/init.d/memcached stop

# mysql (6.0.11)
#RUN rpm -ivh http://mirrors.sohu.com/mysql/MySQL-6.0/MySQL-server-6.0.11-0.glibc23.x86_64.rpm
RUN rpm -Uvh http://dev.mysql.com/get/mysql57-community-release-el6-7.noarch.rpm
RUN yum install -y mysql-community-server
RUN /usr/bin/systemctl enable mysqld
RUN /usr/bin/systemctl start mysqld
#RUN /etc/init.d/mysqld start && /etc/init.d/mysqld stop

# redis (2.8.6)
RUN wget http://download.redis.io/releases/redis-2.8.6.tar.gz && tar xzf redis-2.8.6.tar.gz && cd redis-2.8.6 && make && make install
RUN sed 's/daemonize no/daemonize yes/' redis-2.8.6/redis.conf > /etc/redis.conf

# Chat Server
# Node.js

# Send msg checker

# Expose Ports
# nginx
EXPOSE 80
EXPOSE 443


# TODO config supervisord.conf
CMD ["/usr/bin/supervisord", "-n"]
