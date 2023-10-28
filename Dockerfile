FROM ubuntu
LABEL author swift

ENV NGINX_VERSION 1.25.3

EXPOSE 1935
EXPOSE 80

RUN mkdir -p /opt/data && mkdir /www

# Build dependencies.
RUN apt update
RUN apt-get install -y wget
RUN apt-get install -y build-essential
RUN apt-get install -y libpcre3-dev libssl-dev zlib1g-dev libgd-dev

# Get nginx source.
RUN cd /tmp && \
  wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
  tar zxf nginx-${NGINX_VERSION}.tar.gz && \
  rm nginx-${NGINX_VERSION}.tar.gz

COPY ./nginx-http-flv-module /tmp/nginx-http-flv-module

# Compile nginx with nginx-http-flv module.
RUN cd /tmp/nginx-${NGINX_VERSION} && \
  ./configure \
  --prefix=/opt/nginx \
  --add-module=/tmp/nginx-http-flv-module \
  --conf-path=/opt/nginx/nginx.conf \
  --error-log-path=/opt/nginx/logs/error.log \
  --http-log-path=/opt/nginx/logs/access.log \
  --with-debug && \
  cd /tmp/nginx-${NGINX_VERSION} && make && make install

# Inatall FFmpeg
RUN apt-get install -y ffmpeg

# Cleanup.
RUN rm -rf /var/cache/* /tmp/*

# Add NGINX config and static files.
ADD ./nginx.conf /opt/nginx/nginx.conf
ADD ./static /www/static

RUN mkdir -p /var/log/nginx

CMD ["/opt/nginx/sbin/nginx"]
