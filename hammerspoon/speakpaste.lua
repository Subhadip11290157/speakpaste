recording = false
cmdFile = "/tmp/recorder.cmd"

hs.hotkey.bind({"ctrl", "alt"}, "D", function()
    if not recording then
        recording = true
        hs.alert.show("🎙️ Recording")
        hs.execute("echo START > " .. cmdFile)
    else
        recording = false
        hs.alert.show("🧠 Transcribing")
        hs.execute("echo STOP > " .. cmdFile)

        -- run whisper asynchronously
        hs.task.new(
            "/Users/subhadir/speakpaste/transcribe.sh",
            function(exitCode, stdout, stderr)
                -- small delay to ensure clipboard is ready
                hs.timer.doAfter(0.1, function()
                    hs.eventtap.keyStroke({"cmd"}, "v")
                end)
            end
        ):start()
    end
end)