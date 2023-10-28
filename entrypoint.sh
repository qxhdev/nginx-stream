#!/bin/bash

if [ -f "/script/ffmpeg.sh" ];then
    echo '启动ffmpeg脚本'
    /script/ffmpeg.sh &
fi

/opt/nginx/sbin/nginx