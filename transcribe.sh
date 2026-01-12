#!/usr/bin/env bash
set -e

# --------------------------------------------------
# Resolve project root (directory containing this script)
# --------------------------------------------------
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --------------------------------------------------
# Paths (all relative to project root)
# --------------------------------------------------
VENV_PYTHON="$REPO_ROOT/venv/bin/python"

WHISPER_CPP="$REPO_ROOT/whisper.cpp"
BIN="$WHISPER_CPP/build/bin/whisper-cli"
MODEL="$WHISPER_CPP/models/ggml-small.en.bin"

AUDIO="$REPO_ROOT/recording.wav"
RAW="$REPO_ROOT/transcript_raw.txt"
CLEAN="$REPO_ROOT/transcript.txt"

CLEAN_SCRIPT="$REPO_ROOT/clean_text.py"

# --------------------------------------------------
# Sanity checks (fail fast)
# --------------------------------------------------
[ -x "$VENV_PYTHON" ] || { echo "ERROR: venv python not found at $VENV_PYTHON"; exit 1; }
[ -x "$BIN" ] || { echo "ERROR: whisper-cli not found at $BIN"; exit 1; }
[ -f "$MODEL" ] || { echo "ERROR: Whisper model not found at $MODEL"; exit 1; }
[ -f "$AUDIO" ] || { echo "ERROR: recording.wav not found"; exit 1; }
[ -f "$CLEAN_SCRIPT" ] || { echo "ERROR: clean_text.py not found"; exit 1; }

# --------------------------------------------------
# Transcribe
# --------------------------------------------------
cd "$WHISPER_CPP"

"$BIN" \
  -m "$MODEL" \
  -f "$AUDIO" \
  --no-timestamps \
  > "$RAW"

# --------------------------------------------------
# Clean text (using venv python)
# --------------------------------------------------
"$VENV_PYTHON" "$CLEAN_SCRIPT" < "$RAW" > "$CLEAN"

# --------------------------------------------------
# Copy to clipboard
# --------------------------------------------------
pbcopy < "$CLEAN"

# Notify Hammerspoon we're done
echo "DONE"
