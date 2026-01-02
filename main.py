import asyncio
import json
import logging
import os
from dotenv import load_dotenv
from aiomqtt import Client, MqttError
from pidog import Pidog
from robot_hat.tts import Espeak

from pidog.preset_actions import howling


# Load credentials from .env file
load_dotenv()
abspath = os.path.abspath(os.path.dirname(__file__))
print(abspath)
os.chdir(abspath)

logging.info("\033[033mNote that you need to run with \"sudo\", otherwise there may be no sound.\033[m")

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("PiDogProxy")

class PiDogProxy:
    def __init__(self):
        # Configuration from Environment Variables
        self.broker = os.getenv("MQTT_BROKER")
        self.port = int(os.getenv("MQTT_PORT", 1883))
        self.username = os.getenv("MQTT_USER")
        self.password = os.getenv("MQTT_PASS")
        
        # Hardware Initialization
        self.dog = Pidog()
        self.tts = Espeak(device="robothat")
        #self.ulrasonic  = Ultrasonic(trig=Pin("D2"), echo=Pin("D3"))

        self.cmd_queue = asyncio.Queue()

    async def hardware_worker(self):
        """Processes commands: Actions, TTS, and RGB."""
        while True:
            cmd = await self.cmd_queue.get()
            try:
                target = cmd.get("target")
                p = cmd.get("params", {})

                if target == "action":
                    await asyncio.to_thread(self.dog.do_action, p.get("name", "sit"), speed=p.get("speed", 50))
                    await asyncio.to_thread(self.dog.wait_all_done)

                elif target == "tts":
                    await asyncio.to_thread(self.tts.say, p.get("text", ""))

                elif target == "rgb":

                    await asyncio.to_thread(
                        self.dog.rgb_strip.set_mode, 
                        style=p.get("style", "breath"), 
                        color=p.get("color", "pink"),
                        bps=p.get("bps", 1),
                        brightness=p.get("brightness", 0.5)
                    )
                elif target == "head":

                    yaw = p.get("yaw", 0)
                    roll = p.get("roll", 0)
                    pitch = p.get("pitch", 0)
                    speed = p.get("speed", 50)
                    # Execute the head move
                    await asyncio.to_thread(self.dog.head_move, [[yaw, roll, pitch]], speed=speed)
                    await asyncio.to_thread(self.dog.wait_head_done)

                elif target == "speak":

                    asset = p.get("asset", "")
                    volume = p.get("volume", 50)
                    await asyncio.to_thread(self.dog.speak, asset, volume = volume)

                elif target == "sleep":

                    duration = p.get("duration", 0)
                    await asyncio.sleep(duration)

                elif target == 'howling':

                    await asyncio.to_thread(howling, self.dog)

                else:
                    logging.info(f"Warning unrecognised command {target}")

            except Exception as e:
                logger.error(f"Hardware Logic Error: {e}")
            finally:
                self.cmd_queue.task_done()


    def listen(self):
        if self.dog.ears.isdetected():
            return self.dog.ears.read()
        return -1

    async def sensor_publisher(self, client):
        """Streams sensor data to MQTT."""
        while True:
            try:
                dist = await asyncio.to_thread(self.dog.read_distance)
                touch = await asyncio.to_thread(self.dog.dual_touch.read)
                angle = await asyncio.to_thread(self.listen)
                payload = {"ultrasonic": dist, "touch": touch, "sound": angle}
                await client.publish("pidog/out/state", payload=json.dumps(payload))
                
                await asyncio.sleep(0.2)
            except Exception as e:
                logger.error(f"Sensor Loop Error: {e}")
                await asyncio.sleep(1)

    async def mqtt_manager(self):
        """Resilient connection manager."""
        while True:
            try:
                async with Client(
                    hostname=self.broker,
                    port=self.port,
                    username=self.username,
                    password=self.password
                ) as client:
                    logger.info("K-9 Link Established.")
                    await client.subscribe("pidog/in/#")
                    
                    # Run sensor polling as a concurrent task
                    sensor_task = asyncio.create_task(self.sensor_publisher(client))
                    
                    async for message in client.messages:
                        try:
                            data = json.loads(message.payload.decode())
                            await self.cmd_queue.put(data)
                        except json.JSONDecodeError:
                            logger.warning("Dropped malformed JSON.")

            except MqttError as e:
                logger.error(f"Link Lost: {e}. Reconnecting...")
                await asyncio.sleep(5)

    def cleanup(self):
        """Stops the robot safely."""
        logger.info("Safely shutting down hardware...")
        self.dog.rgb_strip.close()
        self.dog.close()

    async def run(self):
        try:
            await asyncio.gather(
                self.mqtt_manager(),
                self.hardware_worker()
            )
        finally:
            self.cleanup()

if __name__ == "__main__":
    proxy = PiDogProxy()
    try:
        asyncio.run(proxy.run())
    except KeyboardInterrupt:
        logger.info("User requested shutdown.")


