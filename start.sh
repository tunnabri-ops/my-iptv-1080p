#!/bin/sh

mkdir -p /app/live

# বাংলাদেশ টাইমজোন সেট
export TZ="Asia/Dhaka"

# লোগো ডাউনলোড
wget -q -O /app/maxtv.jpg "https://static.wikia.nocookie.net/logopedia/images/4/4d/Maxtv.jpg"

# Nginx স্টার্ট
nginx

# সময় টিভির মতো রিয়েল-টাইম লাইভ ঘড়ি + লোগো
ffmpeg -re \
  -f concat -safe 0 -protocol_whitelist file,http,https,tcp,tls -stream_loop -1 -i /app/playlist.txt \
  -i /app/maxtv.jpg \
  -filter_complex \
  "[0:v]scale=1280:720,fps=25[base]; \
   [1:v]scale=120:-1[logo]; \
   [base]drawbox=x=W-135:y=H-105:w=135:h=30:color=black@0.7:t=fill, \
   drawtext=fontfile=/usr/share/fonts/dejavu/DejaVuSans-Bold.ttf:text='%{localtime\:%I\:%M\:%S %p}':fontcolor=white:fontsize=15:x=W-125:y=H-98[base_time]; \
   [base_time][logo]overlay=W-w-10:H-h-15[v_out]" \
  -map "[v_out]" -map 0:a:0 \
  -c:v libx264 -preset ultrafast -tune zerolatency -crf 28 -g 50 -keyint_min 50 -sc_threshold 0 -threads 2 \
  -c:a aac -b:a 96k -ar 44100 \
  -f hls -hls_time 3 -hls_list_size 10 -hls_flags delete_segments \
  /app/live/stream.m3u8
