#!/usr/bin/env bash
set -e

echo "▶ SpeakPaste — full setup starting"

# --------------------------------------------------
# Resolve repo root
# --------------------------------------------------
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "✔ Repo root: $REPO_ROOT"

# --------------------------------------------------
# 0. Prerequisites: Homebrew, build tools, Hammerspoon, Python
# --------------------------------------------------
echo "▶ Checking system prerequisites"

# Homebrew
if ! command -v brew >/dev/null 2>&1; then
  echo "▶ Homebrew not found — installing"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo "✔ Homebrew installed"
else
  echo "✔ Homebrew already installed"
fi

# Ensure brew available (Apple Silicon)
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Build tools
echo "▶ Ensuring build tools (make, cmake)"
brew install make cmake || true

# Python
if ! command -v python3 >/dev/null 2>&1; then
  echo "▶ python3 not found — installing via Homebrew"
  brew install python
fi

echo "✔ System tools ready"

# Hammerspoon
echo "▶ Ensuring Hammerspoon is installed"
brew install --cask hammerspoon || true
echo "✔ Hammerspoon installed (or already present)"

# --------------------------------------------------
# Paths
# --------------------------------------------------
VENV_DIR="$REPO_ROOT/venv"
PYTHON="$VENV_DIR/bin/python"
PIP="$VENV_DIR/bin/pip"

SPEAKPASTE_LUA="$REPO_ROOT/hammerspoon/speakpaste.lua"
DAEMON_PY="$REPO_ROOT/recorder_daemon.py"

WHISPER_CPP_DIR="$REPO_ROOT/whisper.cpp"
WHISPER_BIN="$WHISPER_CPP_DIR/build/bin/whisper-cli"

LAUNCHD_PLIST="$HOME/Library/LaunchAgents/com.local.speakpaste.recorder.plist"

# --------------------------------------------------
# 1. Python virtual environment
# --------------------------------------------------
echo "▶ Setting up Python virtual environment"

if [ ! -d "$VENV_DIR" ]; then
  python3 -m venv "$VENV_DIR"
  echo "✔ venv created"
else
  echo "✔ venv already exists"
fi

echo "▶ Installing Python dependencies"
"$PIP" install --upgrade pip
"$PIP" install sounddevice soundfile numpy pynput
echo "✔ Python dependencies installed"

# --------------------------------------------------
# 2. Build whisper.cpp if needed
# --------------------------------------------------
echo "▶ Ensuring whisper.cpp is built"

if [ ! -d "$WHISPER_CPP_DIR" ]; then
  echo "❌ whisper.cpp submodule not found. Did you clone with --recurse-submodules?"
  exit 1
fi

if [ ! -x "$WHISPER_BIN" ]; then
  echo "▶ whisper-cli not found — building whisper.cpp"
  cd "$WHISPER_CPP_DIR"
  make
  echo "✔ whisper.cpp built"
else
  echo "✔ whisper.cpp already built"
fi

cd "$REPO_ROOT"

# --------------------------------------------------
# 3. Install launchd recorder daemon
# --------------------------------------------------
echo "▶ Installing recorder daemon (launchd)"

if [ ! -f "$DAEMON_PY" ]; then
  echo "❌ recorder_daemon.py not found at $DAEMON_PY"
  exit 1
fi

cat > "$LAUNCHD_PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.local.speakpaste.recorder</string>

  <key>ProgramArguments</key>
  <array>
    <string>$PYTHON</string>
    <string>$DAEMON_PY</string>
  </array>

  <key>RunAtLoad</key>
  <true/>

  <key>KeepAlive</key>
  <true/>

  <key>StandardOutPath</key>
  <string>/tmp/speakpaste-recorder.out</string>

  <key>StandardErrorPath</key>
  <string>/tmp/speakpaste-recorder.err</string>
</dict>
</plist>
EOF

launchctl unload "$LAUNCHD_PLIST" 2>/dev/null || true
launchctl load "$LAUNCHD_PLIST"

echo "✔ Recorder daemon installed and started"

# --------------------------------------------------
# 4. Configure Hammerspoon (composition)
# --------------------------------------------------
echo "▶ Configuring Hammerspoon"

if [ ! -f "$SPEAKPASTE_LUA" ]; then
  echo "❌ speakpaste.lua not found at $SPEAKPASTE_LUA"
  exit 1
fi

HAMMER_DIR="$HOME/.hammerspoon"
HAMMER_INIT="$HAMMER_DIR/init.lua"

MARKER_START="-- >>> speakpaste (auto-managed)"
MARKER_END="-- <<< speakpaste"
INCLUDE_LINE="dofile(\"$SPEAKPASTE_LUA\")"

mkdir -p "$HAMMER_DIR"
touch "$HAMMER_INIT"

if grep -q "$MARKER_START" "$HAMMER_INIT"; then
  echo "✔ Hammerspoon already configured"
else
  echo "▶ Injecting speakpaste.lua into init.lua"
  {
    echo ""
    echo "$MARKER_START"
    echo "$INCLUDE_LINE"
    echo "$MARKER_END"
  } >> "$HAMMER_INIT"
  echo "✔ Injection complete"
fi

# --------------------------------------------------
# 5. Final guidance
# --------------------------------------------------
echo ""
echo "✅ SpeakPaste setup complete"
echo ""
echo "MANUAL ONE-TIME STEPS (required by macOS):"
echo "  1. Open Hammerspoon → Reload Config"
echo "  2. System Settings → Privacy & Security:"
echo "     - Accessibility → enable Hammerspoon"
echo "     - Input Monitoring → enable Hammerspoon"
echo "     - Microphone → enable Terminal / Python"
echo "  3. System Settings → Login Items:"
echo "     - Set Hammerspoon.app to Open at Login"
echo ""
echo "After this, press ⌃⌥D anywhere to Speak & Paste."
