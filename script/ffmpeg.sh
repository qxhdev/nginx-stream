#!/bin/bash

echo '执行ffmpeg脚本'

sleep 3

nohup ffmpeg -stream_loop -1 -re -i /script/360p.mp4 -vcodec copy -acodec copy -f flv rtmp://localhost:1935/live/360p &
