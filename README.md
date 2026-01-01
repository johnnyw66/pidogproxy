# PiDog MQTT Async Proxy

A resilient, asynchronous Python proxy that allows a SunFounder PiDog to be controlled via MQTT. 
It uses `asyncio` to ensure sensor data remains streaming even while the robot is performing physical actions.

## 🛠 Features
- **Resilient MQTT**: Automatically reconnects if the broker or Wi-Fi drops.
- **Non-Blocking**: Uses threading to prevent hardware movements from freezing the MQTT loop.
- **Secure**: Uses `.env` for credential management.
- **Integrated Sensors**: Publishes Ultrasonic and Touch sensor data back to the broker.

---

## 📡 MQTT API (Incoming)
Send JSON payloads to the topic: `pidog/in/`

### 1. Perform an Action
**Topic:** `pidog/in/`
```json
{
  "target": "action",
  "params": {
    "name": "sit",
    "speed": 80
  }
}

```

### 2. Text-to-Speech (TTS)

**Topic:** `pidog/in/`

```json
{
  "target": "tts",
  "params": {
    "text": "Affirmative, Master."
  }
}

```

### 3. LED Panel Control

**Topic:** `pidog/in/`

```json
{
  "target": "rgb",
  "params": {
    "style": "breath",
    "color": "pink",
    "brightness": 0.5
  }
}

```

---

## 🛰 MQTT API (Outgoing)

The PiDog publishes its state every 200ms to: `pidog/out/state`

**Example Payload:**

```json
{
  "ultrasonic": 25.4,
  "touch": "head"
}

```

---

## 🚀 Setup

1. Clone the repository.
2. Create a `.env` file based on the template below.
3. Install dependencies:
```bash
pip install -r requirements.txt

```


4. Run the proxy:
```bash
python3 main.py

```




