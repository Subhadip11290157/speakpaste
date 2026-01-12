from pynput import keyboard
import sounddevice as sd
import soundfile as sf
import numpy as np
import threading
from constants import RECORDING_WAV


SAMPLE_RATE = 16000
CHANNELS = 1
OUTPUT_FILE = RECORDING_WAV

recording = False
audio_frames = []
stream = None
lock = threading.Lock()
current_keys = set()

def audio_callback(indata, frames, time_info, status):
    if status:
        print(status)
    with lock:
        audio_frames.append(indata.copy())

def start_recording():
    global stream, audio_frames
    audio_frames = []
    stream = sd.InputStream(
        samplerate=SAMPLE_RATE,
        channels=CHANNELS,
        callback=audio_callback
    )
    stream.start()
    print("🎙️ Recording started")

def stop_recording():
    global stream
    stream.stop()
    stream.close()
    stream = None

    with lock:
        audio = np.concatenate(audio_frames, axis=0)

    sf.write(OUTPUT_FILE, audio, SAMPLE_RATE)
    print(f"🛑 Recording stopped → saved to {OUTPUT_FILE}")

def toggle_recording():
    global recording
    if not recording:
        start_recording()
        recording = True
    else:
        stop_recording()
        recording = False

def on_press(key):
    if key == keyboard.KeyCode.from_char('d'):
        if current_keys == {keyboard.Key.ctrl, keyboard.Key.alt}:
            toggle_recording()

def on_release(key):
    current_keys.discard(key)

with keyboard.Listener(
    on_press=lambda key: current_keys.add(key) or on_press(key),
    on_release=on_release
) as listener:
    print("Listening for ⌃⌥D …")
    listener.join()

