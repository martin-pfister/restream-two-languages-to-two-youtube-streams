#!/bin/bash

# This loop ensures that if OBS drops, the listener immediately restarts
trap "exit" SIGTERM SIGINT

while true; do
    echo "============================================="
    echo "Waiting for incoming SRT connection from OBS..."
    echo "============================================="
    SRT_INPUT_URL="srt://0.0.0.0:9000?mode=listener"
    if [ -n "$SRT_INPUT_PASSPHRASE" ]; then
        SRT_INPUT_URL="${SRT_INPUT_URL}&passphrase=${SRT_INPUT_PASSPHRASE}"
    fi

    ffmpeg \
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

