FROM alpine:latest

RUN apk add --no-cache ffmpeg bash

COPY stream.sh /stream.sh
RUN chmod +x /stream.sh

CMD ["/stream.sh"]
