#!/bin/sh

mkdir -p /app/live

# বাংলাদেশ সময় (BST)
export TZ="Asia/Dhaka"

# লোগো নিশ্চিত ডাউনলোড (User-Agent সহ)
curl -k -s -L -A "Mozilla/5.0" "https://static.wikia.nocookie.net/logopedia/images/4/4d/Maxtv.jpg" -o /app/maxtv.jpg

# যদি কোনো কারণে ডাউনলোড ফেইল করে, একটি ব্যাকআপ ইমেজ তৈরি হবে যাতে ক্র্যাশ না হয়
if [ ! -s /app/maxtv.jpg ]; then
  ffmpeg -y -f lavfi -i color=c=red:s=120x60 -vframes 1 /app/maxtv.jpg
fi

# Nginx স্টার্ট
nginx

# সময় টিভির মতো রিয়েল-টাইম ঘড়ি + লোগো
ffmpeg -re \
  -f concat -safe 0 -protocol_whitelist file,http,https,tcp,tls -stream_loop -1 -i /app/playlist.txt \
  -loop 1 -i /app/maxtv.jpg \
  -filter_complex \
  "[0:v]scale=1280:720,fps=25[base]; \
   [1:v]scale=110:-1[logo]; \
   [base]drawbox=x=W-135:y=H-95:w=135:h=26:color=black@0.7:t=fill, \
   drawtext=text='%{localtime\:%I\:%M\:%S %p}':fontcolor=white:fontsize=15:x=W-125:y=H-89[base_time]; \
   [base_time][logo]overlay=W-w-15:H-h-15:shortest=1[v_out]" \
  -map "[v_out]" -map 0:a:0 \
  -c:v libx264 -preset ultrafast -tune zerolatency -crf 28 -g 50 -keyint_min 50 -sc_threshold 0 -threads 2 \
  -c:a aac -b:a 96k -ar 44100 \
  -f hls -hls_time 3 -hls_list_size 10 -hls_flags delete_segments \
  /app/live/stream.m3u8
