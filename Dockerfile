FROM alpine
LABEL author Alfred Gutierrez <alf.g.jr@gmail.com>

ENV NGINX_VERSION 1.9.9
ENV FFMPEG_VERSION 6.0

EXPOSE 1935
EXPOSE 80

RUN mkdir -p /opt/data && mkdir /www

# Build dependencies.
RUN	apk update && apk add	\
  binutils \
  binutils-libs \
  build-base \
  ca-certificates \
  gcc \
  libc-dev \
  libgcc \
  make \
  musl-dev \
  openssl \
  openssl-dev \
  pcre \
  pcre-dev \
  pkgconf \
  pkgconfig \
  zlib-dev

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

# FFmpeg dependencies.
RUN apk add --update nasm yasm-dev lame-dev libogg-dev x264-dev libvpx-dev libvorbis-dev x265-dev freetype-dev libass-dev libwebp-dev rtmpdump-dev libtheora-dev opus-dev
RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories
RUN apk add --update fdk-aac-dev

# Get FFmpeg source.
RUN cd /tmp/ && \
  wget http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.gz && \
  tar zxf ffmpeg-${FFMPEG_VERSION}.tar.gz && rm ffmpeg-${FFMPEG_VERSION}.tar.gz

# Compile ffmpeg.
RUN cd /tmp/ffmpeg-${FFMPEG_VERSION} && \
  ./configure \
  --enable-version3 \
  --enable-gpl \
  --enable-nonfree \
  --enable-small \
  --enable-libmp3lame \
  --enable-libx264 \
  --enable-libx265 \
  --enable-libvpx \
  --enable-libtheora \
  --enable-libvorbis \
  --enable-libopus \
  --enable-libfdk-aac \
  --enable-libass \
  --enable-libwebp \
  --enable-librtmp \
  --enable-postproc \
  --enable-avresample \
  --enable-libfreetype \
  --enable-openssl \
  --disable-debug && \
  make && make install && make distclean

# Cleanup.
RUN rm -rf /var/cache/* /tmp/*

# Add NGINX config and static files.
ADD nginx.conf /opt/nginx/nginx.conf
ADD static /www/static

RUN mkdir -p /var/log/nginx
RUN  ln -sf /dev/stdout /var/log/nginx/access.log \
  && ln -sf /dev/stderr /var/log/nginx/error.log

CMD ["/opt/nginx/sbin/nginx"]
