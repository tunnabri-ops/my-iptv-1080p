FROM alpine:3.19

RUN apk update && \
    apk add --no-cache ffmpeg nginx ttf-dejavu wget curl bash

RUN mkdir -p /app/live /run/nginx

COPY nginx.conf /etc/nginx/http.d/default.conf
COPY start.sh /app/start.sh
COPY playlist.txt /app/playlist.txt

RUN chmod +x /app/start.sh

EXPOSE 80

CMD ["/app/start.sh"]
