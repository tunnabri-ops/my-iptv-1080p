FROM alpine:edge

RUN apk update && apk add --no-cache \
    ffmpeg \
    nginx \
    curl \
    bash

RUN mkdir -p /app/live /run/nginx

WORKDIR /app

COPY nginx.conf /etc/nginx/nginx.conf
COPY playlist.txt /app/playlist.txt
COPY start.sh /app/start.sh

RUN chmod +x /app/start.sh

EXPOSE 80

CMD ["/app/start.sh"]
