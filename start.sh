#!/bin/sh

mkdir -p /app/live

# Nginx স্টার্ট
nginx

# অপ্টিমাইজড ফাস্ট স্ট্রিমিং (CPU লোড কমিয়ে 1.0x+ স্পিড বজায় রাখবে)
ffmpeg -re \
  -f concat -safe 0 -protocol_whitelist file,http,https,tcp,tls -stream_loop -1 -i /app/playlist.txt \
  -vf "scale=1280:720,fps=25" \
  -c:v libx264 -preset ultrafast -tune zerolatency -crf 28 -threads 2 \
  -c:a aac -b:a 96k -ar 44100 \
  -f hls -hls_time 4 -hls_list_size 5 -hls_flags delete_segments \
  /app/live/stream.m3u8
