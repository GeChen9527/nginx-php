FROM php:7.1-fpm

ENV NGING_VHOST_DIR /etc/nginx/vhost
ENV NGINX_VERSION tengine-2.2.2
ENV NGINX_URL http://tengine.taobao.org/download/$NGINX_VERSION.tar.gz

RUN mkdir -p /etc/nginx/vhost
RUN mkdir -p /web/lxj 

RUN set -ex \
    && { \
       echo "deb http://mirrors.aliyun.com/debian/ stretch main non-free contrib"; \
       echo "deb-src http://mirrors.aliyun.com/debian/ stretch main non-free contrib"; \
       echo "deb http://mirrors.aliyun.com/debian-security stretch/updates main"; \
       echo "deb-src http://mirrors.aliyun.com/debian-security stretch/updates main"; \
       echo "deb http://mirrors.aliyun.com/debian/ stretch-updates main non-free contrib"; \
       echo "deb-src http://mirrors.aliyun.com/debian/ stretch-updates main non-free contrib"; \
       echo "deb http://mirrors.aliyun.com/debian/ stretch-backports main non-free contrib"; \
       echo "deb-src http://mirrors.aliyun.com/debian/ stretch-backports main non-free contrib"; \
    } > /etc/apt/sources.list

RUN apt-get update -qq; \
    apt-get install -y libpcre3 libpcre3-dev openssl libssl-dev zlib* wget supervisor; \
    wget -c "$NGINX_URL"; \
    tar -zxvf ${NGINX_VERSION}.tar.gz; \
    cd tengine-2.2.2; \
    ./configure \
	--prefix=/usr/local/nginx \
	--conf-path=/etc/nginx/nginx.conf \
	--error-log-path=/var/log/nginx/error.log \
	--http-log-path=/var/log/nginx/access.log \
	--user=www-data \
	--group=www-data \
	--with-http_v2_module \
	--with-http_stub_status_module \
	--with-ipv6 \
	--with-http_gzip_static_module \
	--with-http_realip_module \
	--with-http_ssl_module \
    ; \
    make -j "$(nproc)"; \
    make install

COPY supervisord.conf /etc/supervisord.conf    
EXPOSE 80
CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]
