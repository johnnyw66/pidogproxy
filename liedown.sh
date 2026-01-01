
# Make him lie down
./k9_cmd.sh rgb '{"style": "boom", "color": "green"}'

./k9_cmd.sh action '{"name": "lie", "speed": 1000}'

./k9_cmd.sh tts '{"text": "I will monitor and alert you on any opportunities."}'

sleep 4

./k9_cmd.sh rgb '{"style": "boom", "color": "black"}'

