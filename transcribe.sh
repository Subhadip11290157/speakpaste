#!/usr/bin/env bash
set -e

# --------------------------------------------------
# Resolve project root
# --------------------------------------------------
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --------------------------------------------------
# Paths
# --------------------------------------------------
VENV_PYTHON="$REPO_ROOT/venv/bin/python"

WHISPER_CPP="$REPO_ROOT/whisper.cpp"
BIN="$WHISPER_CPP/build/bin/whisper-cli"

MODEL_NAME="small.en"
MODEL="$WHISPER_CPP/models/ggml-${MODEL_NAME}.bin"

AUDIO="$REPO_ROOT/recording.wav"
RAW="$REPO_ROOT/transcript_raw.txt"
CLEAN="$REPO_ROOT/transcript.txt"

CLEAN_SCRIPT="$REPO_ROOT/clean_text.py"

# --------------------------------------------------
# Sanity checks
# --------------------------------------------------
[ -x "$VENV_PYTHON" ] || { echo "❌ venv python not found"; exit 1; }
[ -x "$BIN" ] || { echo "❌ whisper-cli not built. Run setup.sh"; exit 1; }
[ -f "$AUDIO" ] || { echo "❌ recording.wav not found"; exit 1; }
[ -f "$CLEAN_SCRIPT" ] || { echo "❌ clean_text.py not found"; exit 1; }

# --------------------------------------------------
# Ensure model exists (self-healing)
# --------------------------------------------------
if [ ! -f "$MODEL" ]; then
  echo "▶ Whisper model missing — downloading ($MODEL_NAME)"
  cd "$WHISPER_CPP"

  if [ ! -x "./models/download-ggml-model.sh" ]; then
    echo "❌ Model download script missing"
    exit 1
  fi

  ./models/download-ggml-model.sh "$MODEL_NAME"

  [ -f "$MODEL" ] || { echo "❌ Model download failed"; exit 1; }
fi

# --------------------------------------------------
# Validate whisper-cli runtime
# --------------------------------------------------
if ! "$BIN" --help >/dev/null 2>&1; then
  echo "❌ whisper-cli is broken (dyld / build issue). Rebuild whisper.cpp"
  exit 1
fi

# --------------------------------------------------
# Validate audio file freshness
# --------------------------------------------------
if [ ! -s "$AUDIO" ]; then
  echo "❌ recording.wav is empty"
  exit 1
fi

# --------------------------------------------------
# Transcribe
# --------------------------------------------------
cd "$WHISPER_CPP"

if ! "$BIN" \
    -m "$MODEL" \
    -f "$AUDIO" \
    --no-timestamps \
    > "$RAW"; then
  echo "❌ Whisper transcription failed"
  exit 1
fi

# --------------------------------------------------
# Clean text
# --------------------------------------------------
"$VENV_PYTHON" "$CLEAN_SCRIPT" < "$RAW" > "$CLEAN"

if [ ! -s "$CLEAN" ]; then
  echo "❌ Cleaned transcript is empty"
  exit 1
fi

# --------------------------------------------------
# Copy to clipboard
# --------------------------------------------------
pbcopy < "$CLEAN"
echo "✔ SpeakPaste: transcription complete"
