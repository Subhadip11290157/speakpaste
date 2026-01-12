import sounddevice as sd
import soundfile as sf
import numpy as np
import threading
import os
import time
from constants import RECORDING_WAV

SAMPLE_RATE = 16000
CHANNELS = 1
OUTPUT_FILE = RECORDING_WAV
CMD_FILE = "/tmp/recorder.cmd"

audio_frames = []
recording = False
lock = threading.Lock()

def audio_callback(indata, frames, time_info, status):
    if recording:
        with lock:
            audio_frames.append(indata.copy())

def command_loop():
    global recording, audio_frames
    while True:
        if os.path.exists(CMD_FILE):
            with open(CMD_FILE) as f:
                cmd = f.read().strip().split()[-1]
            os.remove(CMD_FILE)

            if cmd == "START":
                with lock:
                    audio_frames = []
                recording = True
                print("🎙️ Recorder started")

            elif cmd == "STOP":
                recording = False
                with lock:
                    print(f"Frames captured: {len(audio_frames)}")
                    if audio_frames:
                        audio = np.concatenate(audio_frames, axis=0)
                        print(f"Audio samples: {audio.shape}")
                        sf.write(OUTPUT_FILE, audio, SAMPLE_RATE)
                        print(f"🛑 Recorder stopped → saved {OUTPUT_FILE}")
                    else:
                        print("⚠️ No audio captured")

        time.sleep(0.05)

stream = sd.InputStream(
    samplerate=SAMPLE_RATE,
    channels=CHANNELS,
    callback=audio_callback
)

stream.start()
print("Recorder daemon running")

command_loop()

