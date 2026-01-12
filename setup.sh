#!/usr/bin/env bash
set -e

echo "▶ SpeakPaste — full setup starting"

# --------------------------------------------------
# Resolve repo root
# --------------------------------------------------
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "✔ Repo root: $REPO_ROOT"

# --------------------------------------------------
# 0. Prerequisites: Homebrew, build tools, Hammerspoon
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

# Ensure brew is available in this shell (Apple Silicon)
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Build tools
echo "▶ Ensuring build tools (make, cmake)"
brew install make cmake || true
echo "✔ Build tools ready"

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
LAUNCHD_PLIST="$HOME/Library/LaunchAgents/com.local.speakpaste.recorder.plist"

# --------------------------------------------------
# 1. Python virtual environment
# --------------------------------------------------
echo "▶ Setting up Python virtual environment"

if [ ! -d "$VENV_DIR" ]; then
  echo "✔ Creating venv"
  python3 -m venv "$VENV_DIR"
else
  echo "✔ venv already exists"
fi

echo "✔ Installing Python dependencies"
"$PIP" install --upgrade pip
"$PIP" install sounddevice soundfile numpy pynput

# --------------------------------------------------
# 2. Install launchd daemon
# --------------------------------------------------
echo "▶ Installing recorder daemon (launchd)"

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
# 3. Hammerspoon config injection (composition)
# --------------------------------------------------
echo "▶ Configuring Hammerspoon"

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
# 4. Final guidance
# --------------------------------------------------
echo ""
echo "✅ Automated setup complete"
echo ""
echo "MANUAL STEPS REQUIRED (macOS security):"
echo "  1. Open Hammerspoon → Reload Config"
echo "  2. System Settings → Privacy & Security:"
echo "     - Accessibility → enable Hammerspoon"
echo "     - Input Monitoring → enable Hammerspoon"
echo "     - Microphone → enable Terminal/Python"
echo "  3. System Settings → Login Items:"
echo "     - Ensure Hammerspoon.app is set to Open at Login"
echo ""
echo "Then press ⌃⌥D anywhere to Speak & Paste."
