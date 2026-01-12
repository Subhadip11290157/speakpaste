⚠️ Required User Actions (macOS)

SpeakPaste relies on macOS system permissions and background services.
If any step below is skipped, the hotkey may appear to do nothing.

Please complete ALL steps.

--------------------------------------------------

## 1. Ensure Hammerspoon Starts at Login (MANDATORY)

The dictation hotkey exists only while Hammerspoon is running.

Steps:
- Open System Settings
- Go to General → Login Items
- Under “Open at Login”, ensure:
  - Hammerspoon.app is listed and enabled

If Hammerspoon is not running, ⌃⌥D will not work — even if the recorder
daemon is active.

--------------------------------------------------

## 2. Reload Hammerspoon Configuration

After installing or updating SpeakPaste:

- Click the Hammerspoon icon in the macOS menu bar
- Select “Reload Config”

This is required for the hotkey to become active.

--------------------------------------------------

## 3. Grant Accessibility Permission (MANDATORY)

Hammerspoon requires Accessibility access to:
- detect global hotkeys
- paste text at the cursor

Steps:
- Open System Settings
- Go to Privacy & Security → Accessibility
- Enable:
  - Hammerspoon

If Hammerspoon is not listed:
- Launch Hammerspoon once
- Reload config
- Revisit Accessibility settings

--------------------------------------------------

## 4. Grant Input Monitoring Permission (MANDATORY)

Input Monitoring is required for reliable key detection.

Steps:
- Open System Settings
- Go to Privacy & Security → Input Monitoring
- Enable:
  - Hammerspoon

Restart Hammerspoon after enabling.

--------------------------------------------------

## 5. Grant Microphone Permission (MANDATORY)

The recorder daemon needs microphone access.

Steps:
- Open System Settings
- Go to Privacy & Security → Microphone
- Enable access for:
  - Terminal
  - Python (if prompted)

If recording produces an empty or silent WAV file, this is the cause.

--------------------------------------------------

## 6. How Background Recording Works (FYI)

- Audio recording runs via a launchd agent
- It starts automatically at login
- It does NOT appear in “Login Items”
- This is expected macOS behavior

No manual action is required here.

--------------------------------------------------

## 7. First-Time Test Checklist

After completing all steps:

- Open any text field (Notes, browser, editor)
- Press ⌃⌥D → speak for a few seconds
- Press ⌃⌥D again
- Transcribed text should appear at the cursor

If not:
- Reload Hammerspoon config
- Verify permissions again
- Ensure Hammerspoon is running

--------------------------------------------------

Important Notes

- macOS permissions are user-specific
- Granting permission once is sufficient
- System updates may occasionally reset permissions
- Re-check Privacy & Security if something stops working

--------------------------------------------------

This is not a bug.
This is macOS security working as designed.
