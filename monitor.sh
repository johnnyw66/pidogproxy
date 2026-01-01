#!/bin/bash
# k9_brain.sh - Non-blocking Autonomous Logic

# Load secrets
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "Error: .env missing"; exit 1
fi


./k9_cmd.sh rgb '{"style": "boom", "color": "green"}'
./k9_cmd.sh tts '{"text": "Waiting for sensory input master.."}'


# Cooldown file to prevent spamming actions
COOLDOWN_FILE="/tmp/k9_cooldown"
rm -f $COOLDOWN_FILE

echo "K-9 Brain Active. Monitoring..."

mosquitto_sub -h "$MQTT_BROKER" -p "$MQTT_PORT" \
              -u "$MQTT_USER" -P "$MQTT_PASS" \
              -t "pidog/out/state" | while read -r line
do
    # 1. Parse data
    DIST=$(echo $line | jq '.ultrasonic')
    TOUCH=$(echo $line | jq -r '.touch')

    # 2. Check if we are in a cooldown period (don't act if we just acted)
    if [ -f $COOLDOWN_FILE ]; then
        continue
    fi

    # 3. Logic: Proximity Trigger
    if (( $(echo "$DIST < 15 && $DIST > 0" | bc -l) )); then
        echo "Alert: Object at ${DIST}cm"
        
        # Run the response in a background subshell (...) &
        # This keeps the loop spinning!
        (
            touch $COOLDOWN_FILE
            ./k9_cmd.sh rgb '{"style": "boom", "color": "red"}'
            ./k9_cmd.sh tts '{"text": "Obstacle detected."}'
            #./k9_cmd.sh action '{"name": "backward", "speed": 80}'
            sleep 3 # Wait 3 seconds before allowing another auto-action
            rm $COOLDOWN_FILE
        ) &
    fi

    # 4. Logic: Touch Trigger
    if [ "$TOUCH" != "N" ] && [ "$TOUCH" != "null" ]; then
        echo "Alert: Touch detected on $TOUCH"
        (
            touch $COOLDOWN_FILE
            ./k9_cmd.sh tts '{"text": "Touch sensor active."}'
            ./k9_cmd.sh head '{"roll": 20, "pitch": 10}'
            sleep 2
            rm $COOLDOWN_FILE
        ) &
    fi
done

