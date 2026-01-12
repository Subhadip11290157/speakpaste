import sounddevice as sd
import soundfile as sf
import numpy as np
import threading
import os
import time
from constants import RECORDING_WAV

SAMPLE_RATE = 16000
CHANNELS = 1
CMD_FILE = "/tmp/recorder.cmd"

audio_frames = []
recording = False
lock = threading.Lock()

def audio_callback(indata, frames, time_info, status):
    if status:
        print(f"⚠️ Audio status: {status}")
    with lock:
        if recording:
            audio_frames.append(indata.copy())

def handle_start():
    global recording, audio_frames
    with lock:
        audio_frames = []
        recording = True
    print("🎙️ Recorder started")

def handle_stop():
    global recording
    with lock:
        recording = False
        frames = list(audio_frames)

    print(f"Frames captured: {len(frames)}")

    if not frames:
        print("⚠️ No audio captured")
        return

    audio = np.concatenate(frames, axis=0)
    tmp_file = RECORDING_WAV + ".tmp"

    sf.write(tmp_file, audio, SAMPLE_RATE)
    os.replace(tmp_file, RECORDING_WAV)

    print(f"🛑 Recorder stopped → saved {RECORDING_WAV}")

def command_loop():
    while True:
        if os.path.exists(CMD_FILE):
            try:
                with open(CMD_FILE, "r") as f:
                    cmd = f.read().strip()
            finally:
                os.remove(CMD_FILE)

            if cmd == "START":
                handle_start()
            elif cmd == "STOP":
                handle_stop()
            else:
                print(f"⚠️ Unknown command: {cmd}")

        time.sleep(0.05)

def main():
    print("Available input devices:")
    print(sd.query_devices())

    try:
        stream = sd.InputStream(
            samplerate=SAMPLE_RATE,
            channels=CHANNELS,
            callback=audio_callback
        )
        stream.start()
    except Exception as e:
        print(f"❌ Failed to start audio stream: {e}")
        return

    print("Recorder daemon running")
    command_loop()

if __name__ == "__main__":
    main()
