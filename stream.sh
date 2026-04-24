#!/bin/bash

# This loop ensures that if OBS drops, the listener immediately restarts
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
        -filter_complex "[0:a]pan=stereo|c0=c0|c1=c0[a_en];[0:a]pan=stereo|c0=c1|c1=c1[a_de]" \
        -map 0:v -map "[a_en]" -c:v copy -c:a aac -b:a 160k \
            -f flv "rtmp://a.rtmp.youtube.com/live2/${YT_KEY_EN}" \
        -map 0:v -map "[a_de]" -c:v copy -c:a aac -b:a 160k \
            -f flv "rtmp://a.rtmp.youtube.com/live2/${YT_KEY_DE}"

    echo "FFmpeg exited, restarting in 2 seconds..."
    sleep 2
done

