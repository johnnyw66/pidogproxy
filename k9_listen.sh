#!/bin/bash
# Unified K-9 Monitor Utility

if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "Error: .env file not found."
    exit 1
fi

echo "Listening for PiDog telemetry on $MQTT_BROKER..."
mosquitto_sub -h "$MQTT_BROKER" -p "$MQTT_PORT" \
              -u "$MQTT_USER" -P "$MQTT_PASS" \
              -t "pidog/out/#" -v


