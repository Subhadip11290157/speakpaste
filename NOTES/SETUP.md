# SpeakPaste — Setup Steps

This document explains exactly what `setup.sh` does on a new macOS system.

--------------------------------------------------

## Step 1 — Detect Project Location

The setup script determines the project root dynamically based on the
location of `setup.sh`.

- No hard-coded paths are used
- The repository can be cloned anywhere on disk
- All paths are resolved relative to the project root

--------------------------------------------------

## Step 2 — Ensure System Prerequisites

The script checks for and installs required system tools:

- Homebrew (if not already installed)
- python3
- make
- cmake
- Hammerspoon.app

This ensures the system is capable of:
- building native binaries
- running background services
- capturing global hotkeys
- recording audio

If any tool is already installed, the step is skipped safely.

--------------------------------------------------

## Step 3 — Create Python Virtual Environment

A local Python virtual environment is created at:

./venv/

This ensures:
- no dependency conflicts
- no reliance on system Python
- portability across machines

If the virtual environment already exists, it is reused.

--------------------------------------------------

## Step 4 — Install Python Dependencies

Required Python libraries are installed into the virtual environment:

- sounddevice
- soundfile
- numpy
- pynput

These libraries provide:
- audio capture
- WAV file writing
- keyboard and event handling

--------------------------------------------------

## Step 5 — Build whisper.cpp (Submodule)

The repository includes `whisper.cpp` as a Git submodule.

The script verifies:
- the submodule exists
- the `whisper-cli` binary is present

If the binary is missing, the script runs:

make

inside `whisper.cpp/` to build it.

--------------------------------------------------

## Step 6 — Install Background Recorder (launchd)

A macOS launch agent is installed at:

~/Library/LaunchAgents/com.local.speakpaste.recorder.plist

This ensures:
- the recorder daemon starts automatically at login
- it runs without any terminal window
- it restarts automatically if it crashes

The daemon explicitly uses the project’s virtual environment Python
interpreter.

--------------------------------------------------

## Step 7 — Configure Hammerspoon (Composition)

The script injects the following line into:

~/.hammerspoon/init.lua

dofile("<repo>/hammerspoon/speakpaste.lua")

This is done using clearly marked boundaries so that:

- existing Hammerspoon configuration is preserved
- the operation is idempotent
- removal is trivial

No existing files are overwritten.

--------------------------------------------------

## Step 8 — Manual macOS Permissions (Required)

Due to macOS security restrictions, the following must be done manually
(one-time setup):

- Grant Accessibility permission to Hammerspoon
- Grant Input Monitoring permission to Hammerspoon
- Grant Microphone access to Terminal / Python
- Set Hammerspoon.app to “Open at Login”
- Reload Hammerspoon configuration once

These steps cannot be automated by scripts.

--------------------------------------------------

## Step 9 — Result

After setup and permissions are complete:

- Control + Option + D starts recording
- Control + Option + D stops recording
- Speech is transcribed locally using Whisper
- Text is pasted at the current cursor position
- No cloud services are used
- No telemetry is sent
- All processing is fully offline

The system persists across reboots.

--------------------------------------------------

This design follows macOS security best practices while providing a
hands-free, always-available dictation workflow.
