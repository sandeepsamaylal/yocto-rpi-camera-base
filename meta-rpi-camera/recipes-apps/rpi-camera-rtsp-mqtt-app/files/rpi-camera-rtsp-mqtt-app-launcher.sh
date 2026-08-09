#!/bin/sh
set -eu

BIN_NEW="/usr/bin/rpi_camera_rtsp_mqtt_app"
BIN_OLD="/usr/bin/camera_still_capture"

if [ -x "$BIN_NEW" ]; then
    APP_BIN="$BIN_NEW"
elif [ -x "$BIN_OLD" ]; then
    APP_BIN="$BIN_OLD"
else
    echo "camera app binary not found" >&2
    exit 1
fi

MQTT_HOST="${MQTT_HOST:-127.0.0.1}"
MQTT_PORT="${MQTT_PORT:-1883}"
MQTT_BASE_TOPIC="${MQTT_BASE_TOPIC:-camera/pi4-01}"
RTSP_HOST="${RTSP_HOST:-127.0.0.1}"
RTSP_PORT="${RTSP_PORT:-8554}"
RTSP_PATH="${RTSP_PATH:-/camera}"
WIDTH="${WIDTH:-1280}"
HEIGHT="${HEIGHT:-720}"
FRAMERATE="${FRAMERATE:-25}"
BITRATE="${BITRATE:-1200000}"
INTRA_PERIOD="${INTRA_PERIOD:-15}"

if "$APP_BIN" --help 2>&1 | grep -q -- "--intra-period"; then
    exec "$APP_BIN" \
        --mqtt-mode \
        --mqtt-host "$MQTT_HOST" \
        --mqtt-port "$MQTT_PORT" \
        --mqtt-base-topic "$MQTT_BASE_TOPIC" \
        --rtsp-host "$RTSP_HOST" \
        --rtsp-port "$RTSP_PORT" \
        --rtsp-path "$RTSP_PATH" \
        --width "$WIDTH" \
        --height "$HEIGHT" \
        --framerate "$FRAMERATE" \
        --bitrate "$BITRATE" \
        --intra-period "$INTRA_PERIOD"
else
    exec "$APP_BIN" \
        --mqtt-mode \
        --mqtt-host "$MQTT_HOST" \
        --mqtt-port "$MQTT_PORT" \
        --mqtt-base-topic "$MQTT_BASE_TOPIC" \
        --rtsp-host "$RTSP_HOST" \
        --rtsp-port "$RTSP_PORT" \
        --rtsp-path "$RTSP_PATH" \
        --width "$WIDTH" \
        --height "$HEIGHT" \
        --framerate "$FRAMERATE" \
        --bitrate "$BITRATE"
fi
