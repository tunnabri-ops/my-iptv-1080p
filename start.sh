#!/bin/sh

mkdir -p /app/live

# লোগো ডাউনলোড
wget -q -O /app/logo.jpg "https://imglink.cc/cdn/-n_ZO1Y3ib.jpg"

# Nginx চালু
nginx

# 1080p লাইভ স্ট্রিমিং কমান্ড
ffmpeg -re \
  -f concat -safe 0 -protocol_whitelist file,http,https,tcp,tls -stream_loop -1 -i /app/playlist.txt \
  -i /app/logo.jpg \
  -filter_complex \
  "[0:v:0]scale=1920:1080,fps=30[base]; \
   [1:v]scale=150:-1[logo]; \
   [base][logo]overlay=W-w-35:35[v_logo]; \
   [v_logo]drawbox=y=ih-55:color=black@0.65:width=iw:height=55:t=fill, \
   drawtext=fontfile=/usr/share/fonts/dejavu/DejaVuSans-Bold.ttf:text='Welcome to my tv channel':fontcolor=yellow:fontsize=26:x=w-mod(t*90\,w+text_w):y=h-40[v_out]" \
  -map "[v_out]" -map 0:a:0 \
  -c:v libx264 -preset ultrafast -tune zerolatency -b:v 2500k -maxrate 2800k -bufsize 5000k \
  -c:a aac -b:a 128k -ar 44100 \
  -f hls -hls_time 4 -hls_list_size 5 -hls_flags delete_segments \
  /app/live/stream.m3u8
