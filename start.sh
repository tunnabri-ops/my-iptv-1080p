#!/bin/sh

mkdir -p /app/live

# লোগো ডাউনলোড
curl -k -s -L "https://static.wikia.nocookie.net/logopedia/images/4/4d/Maxtv.jpg" -o /app/maxtv.jpg || true

# Nginx স্টার্ট
nginx

# স্টেবল স্ট্রিমিং (লোগো সহ)
ffmpeg -re \
  -f concat -safe 0 -protocol_whitelist file,http,https,tcp,tls -stream_loop -1 -i /app/playlist.txt \
  -loop 1 -i /app/maxtv.jpg \
  -filter_complex \
  "[0:v]scale=1280:720,fps=25[base]; \
   [1:v]scale=110:-1[logo]; \
   [base][logo]overlay=W-w-15:H-h-15:shortest=1[v_out]" \
  -map "[v_out]" -map 0:a:0 \
  -c:v libx264 -preset ultrafast -tune zerolatency -crf 28 -g 50 -keyint_min 50 -sc_threshold 0 -threads 2 \
  -c:a aac -b:a 96k -ar 44100 \
  -f hls -hls_time 3 -hls_list_size 10 -hls_flags delete_segments \
  /app/live/stream.m3u8
