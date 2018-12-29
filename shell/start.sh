#!/bin/bash

redis-server /etc/redis.conf --daemonize yes
nginx 
php-fpm7 -R
#/var/www/Gateway/start.php start -d

tail -f /dev/null