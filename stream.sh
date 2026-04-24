#!/bin/bash

# This loop ensures that if OBS drops, the listener immediately restarts
trap "exit" SIGTERM SIGINT

while true; do
    SRT_PORT="${SRT_INPUT_PORT:-9000}"
    PUBLIC_IP=$(curl -s http://ipinfo.io/ip)
    SRT_DISPLAY_URL="srt://${PUBLIC_IP:-<YOUR_SERVER_IP>}:${SRT_PORT}"
    if [ -n "$SRT_INPUT_PASSPHRASE" ]; then
        SRT_DISPLAY_URL="${SRT_DISPLAY_URL}?passphrase=${SRT_INPUT_PASSPHRASE}"
    fi

    echo "============================================="
    echo "Waiting for incoming SRT connection from OBS..."
    echo "Configuring OBS with this URL:"
    echo "  $SRT_DISPLAY_URL"
    echo "============================================="
    
    SRT_PARAMS="mode=listener&latency=2000000&rcvbuf=67108864&sndbuf=67108864&pkt_size=1316"
    SRT_INPUT_URL="srt://0.0.0.0:${SRT_PORT}?${SRT_PARAMS}"
    if [ -n "$SRT_INPUT_PASSPHRASE" ]; then
        SRT_INPUT_URL="${SRT_INPUT_URL}&passphrase=${SRT_INPUT_PASSPHRASE}"
    fi

    ffmpeg \
        -fflags +genpts+discardcorrupt \
        -err_detect ignore_err \
        -i "$SRT_INPUT_URL" \
        -filter_complex "[0:a]pan=stereo|c0=c0|c1=c0,aresample=async=1[a_left];[0:a]pan=stereo|c0=c1|c1=c1,aresample=async=1[a_right]" \
        -map 0:v -map "[a_left]" -c:v copy -c:a aac -b:a 160k \
            -flags +global_header -f flv "rtmp://a.rtmp.youtube.com/live2/${YOUTUBE_KEY_LEFT}" \
        -map 0:v -map "[a_right]" -c:v copy -c:a aac -b:a 160k \
            -flags +global_header -f flv "rtmp://a.rtmp.youtube.com/live2/${YOUTUBE_KEY_RIGHT}" &
    
    FFMPEG_PID=$!
    wait $FFMPEG_PID

    echo "FFmpeg exited, restarting in 2 seconds..."
    sleep 2
done

