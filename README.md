# Local Whisper Dictation (macOS)

A fully local, offline dictation system for macOS built on top of
whisper.cpp, Python, and Hammerspoon.

This project provides a global hotkey–based speech-to-text workflow that:
- records audio locally
- transcribes it using OpenAI Whisper (via whisper.cpp)
- cleans filler words deterministically
- pastes the final text at the cursor
- runs fully offline
- auto-starts at login using launchd

Designed for developers who want to think out loud, explain problems,
and write natural technical prose without relying on cloud services.

--------------------------------------------------

✨ Features

- ⌨ Global hotkey toggle (⌃⌥D)
- 🎙 Start / stop dictation anywhere (browser, IDE, Slack, Notes)
- 🧠 Local Whisper inference (Metal-accelerated)
- 🧹 Deterministic text cleanup (no AI rewriting)
- 📋 Auto-paste at cursor
- 🚀 Auto-starts in background at login
- 🔒 No cloud, no telemetry, no vendor lock-in

--------------------------------------------------

🏗 Architecture Overview

Hammerspoon (hotkey)
        ↓
Python recorder daemon (audio capture)
        ↓
recording.wav
        ↓
whisper.cpp (whisper-cli)
        ↓
raw transcript
        ↓
clean_text.py (regex-based cleanup)
        ↓
clipboard → paste at cursor

Each component is deliberately simple and replaceable.

--------------------------------------------------

🧩 Components

Hammerspoon
- Global hotkey
- Start/stop orchestration
- Paste-at-cursor

Python
- Audio recording daemon
- Deterministic regex-based text cleanup

whisper.cpp
- Local Whisper inference
- Metal + Accelerate backends
- English-only models

--------------------------------------------------

🚀 Usage

1. Log into macOS (daemon starts automatically)
2. Place cursor in any text field
3. Press ⌃⌥D → speak
4. Press ⌃⌥D → stop
5. Text appears at the cursor

--------------------------------------------------

🧠 Model Choice

Default model: ggml-small.en.bin

Why:
- Noticeably higher accuracy than base.en
- Still fast enough for interactive dictation on Apple Silicon

Switching models requires changing one line in transcribe.sh.

--------------------------------------------------

🔒 Privacy

- 100% offline
- No network calls after model download
- No audio or text leaves the machine

--------------------------------------------------

🌿 Cloning

This repository uses a Git submodule.

Clone it using:

git clone --recurse-submodules https://github.com/Subhadip11290157/speakpaste.git

Or after cloning:

git submodule update --init --recursive

--------------------------------------------------

📜 License

This project is for personal use.
Upstream dependencies (e.g. whisper.cpp) retain their respective licenses.

