#!/bin/bash

if [ -f "/script/ffmpeg.sh" ];then
    /script/ffmpeg.sh &
fi

/opt/nginx/sbin/nginx