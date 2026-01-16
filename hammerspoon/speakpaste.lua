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

-- --------------------------------------------------
-- Core toggle logic (shared by ALL triggers)
-- --------------------------------------------------
local function toggleDictation()
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
end

-- --------------------------------------------------
-- Existing hotkey (UNCHANGED)
-- --------------------------------------------------
hs.hotkey.bind({"ctrl", "alt"}, "D", toggleDictation)

-- -- --------------------------------------------------
-- -- Double-tap Option trigger (flagsChanged-based)
-- -- --------------------------------------------------
-- local lastOptionTap = 0
-- local DOUBLE_TAP_THRESHOLD = 0.4

-- local optionTapper = hs.eventtap.new(
--     { hs.eventtap.event.types.flagsChanged },
--     function(event)
--         local flags = event:getFlags()

--         -- Option pressed alone (no other modifiers)
--         if flags.alt and not (flags.cmd or flags.ctrl or flags.shift) then
--             local now = hs.timer.secondsSinceEpoch()

--             if (now - lastOptionTap) <= DOUBLE_TAP_THRESHOLD then
--                 lastOptionTap = 0
--                 toggleDictation()
--             else
--                 lastOptionTap = now
--             end
--         end

--         return false
--     end
-- )

-- optionTapper:start()


