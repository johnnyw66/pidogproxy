
# Make him sit
#./k9_cmd.sh action '{"name": "sit", "speed": 1000}'

# Make him talk
./k9_cmd.sh tts '{"text": "Scanning for lifeforms"}'

# Change the LEDs
./k9_cmd.sh rgb '{"style": "boom", "color": "red"}'

# Look left and Right (Yaw 40, -40)
./k9_cmd.sh head '{"yaw": 40, "speed": 80}'
sleep 1
./k9_cmd.sh head '{"yaw": -40, "speed": 80}'
sleep 1
./k9_cmd.sh head '{"yaw": 40, "speed": 80}'
sleep 1
./k9_cmd.sh head '{"yaw": -40, "speed": 80}'
sleep 1
./k9_cmd.sh head '{"yaw": 40, "speed": 80}'
sleep 1
./k9_cmd.sh head '{"yaw": -40, "speed": 80}'
sleep 4

# Look down and tilt (Pitch -20, Roll 20)
./k9_cmd.sh head '{"pitch": -20, "roll": 20}'

# Reset head to center
./k9_cmd.sh head '{"yaw": 0, "roll": 0, "pitch": 0}'

sleep 10

./k9_cmd.sh tts '{"text": "Nothing found"}'

# Lie down
./k9_cmd.sh action '{"name": "lie", "speed": 1000}'

#
./k9_cmd.sh rgb '{"style": "boom", "color": "black"}'


./k9_cmd.sh tts '{"text": "I will monitor and alert you on any opportunities."}'

