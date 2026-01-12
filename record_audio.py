import sounddevice as sd
import soundfile as sf
import numpy as np
import sys
import threading
import time
from constants import RECORDING_WAV

SAMPLE_RATE = 16000
CHANNELS = 1
OUTPUT_FILE = RECORDING_WAV

audio_frames = []
lock = threading.Lock()

def callback(indata, frames, time_info, status):
    with lock:
        audio_frames.append(indata.copy())

duration = float(sys.argv[1]) if len(sys.argv) > 1 else 5.0

with sd.InputStream(
    samplerate=SAMPLE_RATE,
    channels=CHANNELS,
    callback=callback
):
    time.sleep(duration)

with lock:
    audio = np.concatenate(audio_frames, axis=0)

sf.write(OUTPUT_FILE, audio, SAMPLE_RATE)

