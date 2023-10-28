#!/bin/bash

BASE_DIR=$HOME/data/nginx-stream

if [ ! -d "$BASE_DIR" ];then
  echo '创建gitlab文件夹'
  # 创建文件夹
  mkdir -p "$BASE_DIR"/script
  mkdir -p "$BASE_DIR"/logs
  cp script/* "$BASE_DIR"/script
fi

docker stop nginx-stream || echo 'stop nginx-stream'
docker rm nginx-stream || echo 'rm nginx-stream'


sudo docker run --name nginx-stream -d --restart always \
  -p 180:80 -p 1935:1935 \
  -v "$BASE_DIR"/script:/script \
  -v "$BASE_DIR"/logs:/var/log/nginx/ \
  -v /etc/hosts:/etc/hosts \
  nginx-stream
