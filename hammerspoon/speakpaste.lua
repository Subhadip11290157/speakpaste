recording = false
cmdFile = "/tmp/recorder.cmd"

-- --------------------------------------------------
-- Resolve project root dynamically (NO hardcoding)
-- --------------------------------------------------
local info = debug.getinfo(1, "S")
local thisFile = info.source:sub(2)
-- thisFile = /path/to/speakpaste/hammerspoon/speakpaste.lua
local projectDir = thisFile:match("(.*/)[^/]+$"):gsub("/hammerspoon/$", "")
local transcribeScript = projectDir .. "/transcribe.sh"

hs.hotkey.bind({"ctrl", "alt"}, "D", function()
    if not recording then
        recording = true
        hs.alert.show("🎙️ Recording")
        hs.execute("echo START > " .. cmdFile)
    else
        recording = false
        hs.alert.show("🧠 Transcribing")
        hs.execute("echo STOP > " .. cmdFile)

        -- run whisper asynchronously (guarded, deterministic)
        hs.task.new(
            "/bin/bash",
            function(exitCode, stdout, stderr)
                if exitCode == 0 then
                    hs.eventtap.keyStroke({"cmd"}, "v")
                else
                    hs.alert.show("❌ Transcription failed")
                end
            end,
            { "-lc", transcribeScript }
        ):start()
    end
end)
