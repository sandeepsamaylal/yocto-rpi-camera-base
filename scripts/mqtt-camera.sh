#!/usr/bin/env bash
set -euo pipefail

BROKER_HOST=""
BROKER_PORT="1883"
BASE_TOPIC="camera/pi4-01"
TIMEOUT_SEC="5"

usage() {
    cat <<'EOF'
Usage:
  ./scripts/mqtt-camera.sh [global-options] <command>

Global options:
  --host <ip-or-hostname>    MQTT broker host (required)
  --port <port>              MQTT broker port (default: 1883)
  --topic <base-topic>       Base topic (default: camera/pi4-01)
  --timeout <seconds>        Wait timeout for status commands (default: 5)
  -h, --help                 Show help

Commands:
  start                      Publish control/start
  stop                       Publish control/stop
  restart                    Publish control/restart
  state                      Read one message from status/state
  stream-url                 Read one message from stream/url
  error                      Read one message from error
  watch-status               Watch status/# continuously

Examples:
  ./scripts/mqtt-camera.sh --host 192.168.1.50 start
  ./scripts/mqtt-camera.sh --host 192.168.1.50 state
  ./scripts/mqtt-camera.sh --host 192.168.1.50 --topic camera/pi4-01 watch-status
EOF
}

require_host() {
    if [[ -z "${BROKER_HOST}" ]]; then
        echo "Error: --host is required" >&2
        usage
        exit 1
    fi
}

pub() {
    local suffix="$1"
    mosquitto_pub -h "$BROKER_HOST" -p "$BROKER_PORT" -t "${BASE_TOPIC}/${suffix}" -m '{}'
}

sub_once() {
    local suffix="$1"
    mosquitto_sub -h "$BROKER_HOST" -p "$BROKER_PORT" -t "${BASE_TOPIC}/${suffix}" -v -C 1 -W "$TIMEOUT_SEC"
}

watch_status() {
    mosquitto_sub -h "$BROKER_HOST" -p "$BROKER_PORT" -t "${BASE_TOPIC}/status/#" -v
}

if [[ $# -eq 0 ]]; then
    usage
    exit 1
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        --host)
            BROKER_HOST="$2"
            shift 2
            ;;
        --port)
            BROKER_PORT="$2"
            shift 2
            ;;
        --topic)
            BASE_TOPIC="$2"
            shift 2
            ;;
        --timeout)
            TIMEOUT_SEC="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        start|stop|restart|state|stream-url|error|watch-status)
            CMD="$1"
            shift
            break
            ;;
        *)
            echo "Unknown argument: $1" >&2
            usage
            exit 1
            ;;
    esac
done

if [[ -z "${CMD:-}" ]]; then
    echo "Error: missing command" >&2
    usage
    exit 1
fi

require_host

case "$CMD" in
    start)
        pub "control/start"
        echo "Sent: ${BASE_TOPIC}/control/start"
        ;;
    stop)
        pub "control/stop"
        echo "Sent: ${BASE_TOPIC}/control/stop"
        ;;
    restart)
        pub "control/restart"
        echo "Sent: ${BASE_TOPIC}/control/restart"
        ;;
    state)
        sub_once "status/state"
        ;;
    stream-url)
        sub_once "stream/url"
        ;;
    error)
        sub_once "error"
        ;;
    watch-status)
        watch_status
        ;;
    *)
        echo "Unhandled command: $CMD" >&2
        exit 1
        ;;
esac
