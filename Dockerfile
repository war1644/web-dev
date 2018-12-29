FROM alpine:edge
LABEL author=ahmerry@qq.com
ENV TIMEZONE Asia/Shanghai
# base
RUN mkdir -p /var/www/html && \
    mkdir -p /var/lib/nginx && \
    echo http://mirrors.aliyun.com/alpine/edge/main > /etc/apk/repositories && \
    echo http://mirrors.aliyun.com/alpine/edge/community >> /etc/apk/repositories && \
    # busybox-extras
    apk update && apk upgrade -a && apk add --no-cache tzdata curl bash vim && \
    # 时区
    cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
    echo "${TIMEZONE}" > /etc/timezone

# redis
RUN apk add --no-cache redis && \
    # 去掉安全模式
    sed -i "s|protected-mode yes|protected-mode no|" /etc/redis.conf && \
    # 支持远端连接
    sed -i "s|bind 127.0.0.1|# bind 127.0.0.1|" /etc/redis.conf

# nginx
RUN apk add --no-cache nginx-mod-http-echo

# PHP php7-fpm
RUN apk add --no-cache php7-fpm php7-pdo_mysql php7-mbstring php7-curl php7-gd php7-xmlreader php7-ctype php7-openssl php7-phar php7-pear php7-iconv php7-redis php7-json php7-posix php7-pcntl php7-apcu php7-imagick php7-intl php7-mcrypt php7-fileinfo php7-opcache php7-openssl php7-pdo php7-mysqli php7-xml php7-zlib php7-tokenizer php7-session php7-simplexml php7-zip && \
    # composer
    php -r "copy('https://install.phpcomposer.com/installer', 'composer-setup.php');" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer && \
    # 设置中国镜像源
    composer config -g repo.packagist composer https://packagist.phpcomposer.com

#开放端口
EXPOSE 80 443 6379 9000 9001
#外部配置
COPY php_config/conf /etc/php7/
COPY nginx_config /etc/nginx/
COPY shell /shell

# 健康检查 --interval检查的间隔 超时timeout retries失败次数
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD curl --fail http://localhost || exit 1

# 启动
CMD ["/shell/start.sh"]
