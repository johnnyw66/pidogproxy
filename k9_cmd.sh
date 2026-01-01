#!/bin/bash

# Usage: ./k9_cmd.sh action '{"name": "sit", "speed": 80}'
# 1. Load variables from .env if it exists
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "Error: .env file not found. Please create it with MQTT credentials."
    exit 1
fi

# 2. Check for arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: ./k9_cmd.sh <target> <json_params>"
    echo "Example: ./k9_cmd.sh action '{\"name\":\"sit\"}'"
    exit 1
fi

TARGET=$1
PARAMS=$2

# Construct the JSON payload
PAYLOAD="{\"target\": \"$TARGET\", \"params\": $PARAMS}"

# Send via mosquitto_pub
mosquitto_pub -h "$MQTT_BROKER" -p "$MQTT_PORT" \
              -u "$MQTT_USER" -P "$MQTT_PASS" \
              -t "pidog/in/" -m "$PAYLOAD"

echo "Sent to K-9: $PAYLOAD"


