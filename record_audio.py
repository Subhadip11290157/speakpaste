import sounddevice as sd
import soundfile as sf
import numpy as np
import sys
import os
import threading
import time
from constants import RECORDING_WAV

SAMPLE_RATE = 16000
CHANNELS = 1
OUTPUT_FILE = RECORDING_WAV

audio_frames = []
lock = threading.Lock()

def callback(indata, frames, time_info, status):
    if status:
        print(f"⚠️ Audio status: {status}")
    with lock:
        audio_frames.append(indata.copy())

def parse_duration():
    if len(sys.argv) <= 1:
        return 5.0
    try:
        d = float(sys.argv[1])
        if d <= 0:
            raise ValueError
        return d
    except ValueError:
        print("❌ Duration must be a positive number (seconds)")
        sys.exit(1)

def main():
    duration = parse_duration()

    print("Available input devices:")
    print(sd.query_devices())

    try:
        with sd.InputStream(
            samplerate=SAMPLE_RATE,
            channels=CHANNELS,
            callback=callback
        ):
            print(f"🎙️ Recording for {duration} seconds...")
            time.sleep(duration)
    except Exception as e:
        print(f"❌ Failed to start audio stream: {e}")
        sys.exit(1)

    with lock:
        if not audio_frames:
            print("⚠️ No audio captured")
            sys.exit(1)
        audio = np.concatenate(audio_frames, axis=0)

    tmp_file = OUTPUT_FILE + ".tmp"
    sf.write(tmp_file, audio, SAMPLE_RATE)
    os.replace(tmp_file, OUTPUT_FILE)

    print(f"✅ Saved recording to {OUTPUT_FILE}")

if __name__ == "__main__":
    main()
