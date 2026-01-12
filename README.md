# 🎙️ SpeakPaste

**Fully local, offline voice dictation for macOS — powered by Whisper.**

SpeakPaste lets you press a hotkey, speak naturally, and have your words
**transcribed and pasted directly at the cursor**, anywhere on your Mac.

No cloud.  
No accounts.  
No telemetry.  
No background UI.

Designed for developers and thinkers who like to **think out loud** and
write natural prose without relying on cloud services.

--------------------------------------------------

## ✨ What SpeakPaste Does

- ⌨ Global hotkey toggle (**⌃⌥D**)
- 🎙 Start / stop dictation anywhere (IDE, browser, Notes, chat apps)
- 🧠 Local Whisper inference (via `whisper.cpp`, Metal-accelerated)
- 🧹 Deterministic text cleanup (regex-based, no AI rewriting)
- 📋 Automatically pastes text at the cursor
- 🚀 Runs silently in the background, auto-starts at login
- 🔒 100% offline — no audio or text leaves your machine

--------------------------------------------------

## 🚀 Quick Usage

1. Place the cursor in any text field
2. Press **⌃⌥D** → start speaking
3. Press **⌃⌥D** again → stop
4. Transcribed text appears at the cursor

If you forget it exists, it’s working exactly as intended.

--------------------------------------------------

## 🧠 How It Works (High-Level)

SpeakPaste is intentionally built from small, reliable components:

Hammerspoon  
→ captures the global hotkey and pastes text

Recorder daemon (Python + launchd)  
→ records audio in the background

`whisper.cpp`  
→ performs fully local Whisper transcription

Shell pipeline  
→ cleans text deterministically and copies to clipboard

Each component is simple, explicit, and replaceable.

--------------------------------------------------

## 🏗 Architecture Overview

```
Hotkey (Hammerspoon)
        ↓
Recorder daemon (Python, launchd)
        ↓
recording.wav
        ↓
whisper.cpp (whisper-cli)
        ↓
raw transcript
        ↓
clean_text.py (regex cleanup)
        ↓
clipboard → paste at cursor
```

--------------------------------------------------

## 🧠 Model Choice

**Default model:** `ggml-small.en.bin`

Why:
- Noticeably higher accuracy than `base.en`
- Still fast enough for interactive dictation on Apple Silicon

Switching models requires changing **one line** in `transcribe.sh`.

--------------------------------------------------

## 🔒 Privacy

- All processing is local
- No network calls after model download
- No telemetry, analytics, or vendor lock-in

Your voice never leaves your Mac.

--------------------------------------------------

## 🌿 Installation

This repository uses a **Git submodule** for `whisper.cpp`.

Clone with:

```bash
git clone --recurse-submodules https://github.com/<your-username>/speakpaste.git
cd speakpaste
```

Then run:

```bash
./setup.sh
```

The setup script:
- installs required system tools (Homebrew, make, cmake, Hammerspoon)
- creates a Python virtual environment
- builds `whisper.cpp` if needed
- installs a background recorder daemon
- safely composes Hammerspoon configuration

--------------------------------------------------

## ⚠️ Required macOS Permissions (MANDATORY)

Due to macOS security, a few one-time manual steps are required.

You **must** complete them for the hotkey to work.

➡️ **Read:** `CONDITIONS.md`

Summary:
- Accessibility → Hammerspoon
- Input Monitoring → Hammerspoon
- Microphone → Terminal / Python
- Hammerspoon → Open at Login
- Reload Hammerspoon config once

If any step is skipped, ⌃⌥D may appear to do nothing.
This is macOS security working as designed.

--------------------------------------------------

## 📘 Documentation Index

For details beyond this README:

- **SETUP.md**  
  What `setup.sh` does, step by step

- **DEV_GUIDE.md**  
  Debugging, rebuilding, internals, common failure modes

- **CONDITIONS.md**  
  macOS permissions and background behavior explained clearly

--------------------------------------------------

## 🎯 Design Philosophy

- Offline by default
- Deterministic behavior
- No hidden state
- No cloud dependency
- Simple pieces over monoliths

SpeakPaste prefers being **boringly reliable** over being clever.

--------------------------------------------------

## 📜 License

This project is for personal use.

Upstream dependencies (e.g. `whisper.cpp`) retain their respective licenses.

--------------------------------------------------

## 🧠 Final Note

If SpeakPaste quietly does its job,  
never interrupts your flow,  
and slowly fades into muscle memory — that is not an accident.

That is the goal.
```
