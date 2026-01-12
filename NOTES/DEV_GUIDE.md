# Developer Guide — SpeakPaste

This document contains maintenance notes, debugging commands,
and architectural knowledge for SpeakPaste.

--------------------------------------------------

## Project Structure

speakpaste/
├── setup.sh
├── recorder_daemon.py
├── transcribe.sh
├── clean_text.py
├── recording.wav
├── transcript.txt
├── whisper.cpp/        (git submodule)
│   ├── build/
│   └── models/
├── hammerspoon/
│   └── speakpaste.lua
└── venv/

--------------------------------------------------

## Architecture Overview

- Hammerspoon handles hotkeys and paste events
- A launchd daemon records audio continuously
- A shell script runs Whisper transcription
- Output is copied to the clipboard and pasted

No component blocks another.
All components are restartable independently.

--------------------------------------------------

## Manual Start (Recorder Debugging)

source ./venv/bin/activate
python recorder_daemon.py

Use this to verify:
- microphone access
- audio capture
- WAV file creation

--------------------------------------------------

## launchd Management

Check if the recorder daemon is running:

launchctl list | grep speakpaste

--------------------------------------------------

Stop the daemon temporarily:

launchctl unload ~/Library/LaunchAgents/com.local.speakpaste.recorder.plist

--------------------------------------------------

Start it again:

launchctl load ~/Library/LaunchAgents/com.local.speakpaste.recorder.plist

--------------------------------------------------

Remove permanently:

launchctl unload ~/Library/LaunchAgents/com.local.speakpaste.recorder.plist
rm ~/Library/LaunchAgents/com.local.speakpaste.recorder.plist

--------------------------------------------------

## launchd Logs

Stdout:
 /tmp/speakpaste-recorder.out

Stderr:
 /tmp/speakpaste-recorder.err

--------------------------------------------------

## Audio Debugging

Check if audio is being recorded:

ls -lh recording.wav
afplay recording.wav

If audio plays correctly, the recorder daemon is healthy.

--------------------------------------------------

## Whisper Debugging

Manual transcription test:

cd whisper.cpp
./build/bin/whisper-cli \
  -m models/ggml-small.en.bin \
  -f ../recording.wav \
  --no-timestamps

If text prints, Whisper is functioning correctly.

--------------------------------------------------

## Switching Models

Edit `transcribe.sh`:

MODEL="whisper.cpp/models/ggml-small.en.bin"

Available options:
- ggml-base.en.bin    (fast, lower accuracy)
- ggml-small.en.bin   (balanced, recommended)
- ggml-medium.en.bin  (slow, higher accuracy)

--------------------------------------------------

## Text Cleanup Rules

Rules live in:

clean_text.py

You can:
- add or remove filler words
- disable cleanup entirely
- tune regexes deterministically

No AI rewriting occurs during cleanup.

--------------------------------------------------

## Hotkey Configuration

Defined in:

~/.hammerspoon/init.lua
(or composed from hammerspoon/speakpaste.lua)

Default hotkey:
- ⌃⌥D → start / stop dictation

--------------------------------------------------

## Rebuilding whisper.cpp

cd whisper.cpp
git pull
make

Binaries appear under:

whisper.cpp/build/bin/

--------------------------------------------------

## Common Failure Modes

No text pasted:
- Hammerspoon permissions missing

No audio recorded:
- Recorder daemon not running
- Microphone permission missing

Model not found:
- Model file missing from whisper.cpp/models/

Works manually but not via hotkey:
- launchd agent not loaded
- Hammerspoon not running

--------------------------------------------------

## Design Philosophy

- Determinism over intelligence
- Offline-first by default
- Small composable components
- Explicit state transitions
- No cloud dependencies

--------------------------------------------------

Final note:

If SpeakPaste disappears into the background
and you forget it exists —
it is working exactly as intended.
