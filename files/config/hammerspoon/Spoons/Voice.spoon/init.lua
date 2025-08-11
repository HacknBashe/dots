local Voice = {}
Voice.__index = Voice

-- Metadata
Voice.name = "Voice"
Voice.version = "0.1"
Voice.author = " Nick Hackford"
Voice.license = "MIT - https://opensource.org/licenses/MIT"

hs.hotkey.bind({ "cmd", "alt" }, "v", function()
	if isRecording then
		if recordingProcess then
			recordingProcess:terminate()
			recordingProcess = nil
		end

		hs.alert.show("Recording stopped. Transcribing...")

		hs.task
			.new(
				-- "/etc/profiles/per-user/nhackford/bin/whisper",
				"/etc/profiles/per-user/nhackford/bin/whisper-cli",
				function(exitCode, stdOut, stdErr)
					if exitCode == 0 then
						hs.alert.show("Transcription complete. Processing text...")

						local file = io.open("/tmp/voice.txt", "r")
						if file then
							local text = file:read("*all")
							file:close()

							-- Remove trailing newline if present
							text = text:gsub("\n$", "")

							hs.alert.show("Sending text as keystrokes...")
							hs.eventtap.keyStrokes(text)
							os.execute("rm /tmp/voice.wav /tmp/voice.mp3 /tmp/voice.txt")
						else
							hs.alert.show("Failed to read transcription file")
						end
					else
						hs.alert.show("Transcription failed (exit code: " .. exitCode .. ")")
						hs.console.printStyledtext("STDOUT: " .. (stdOut or ""))
						hs.console.printStyledtext("STDERR: " .. (stdErr or ""))
					end
				end,
				-- { "/tmp/voice.mp3", "--language", "English", "--model", "tiny.en", "--output_dir", "/tmp", "-f", "txt" }
				{ "-m", "/Users/nhackford/models/ggml-large-v3-turbo", "-otxt", "-of", "/tmp/voice", "/tmp/voice.wav" }
			)
			:start()

		isRecording = false
	else
		hs.alert.show("Recording started...")

		recordingProcess = hs
			.task
			-- .new("/etc/profiles/per-user/nhackford/bin/ffmpeg", nil, { "-f", "avfoundation", "-i", ":1", "/tmp/voice.mp3" })
			.new(
				"/etc/profiles/per-user/nhackford/bin/ffmpeg",
				nil,
				{ "-f", "avfoundation", "-i", ":1", "-ar", "16000", "/tmp/voice.wav" }
			)
			:start()

		isRecording = true
	end
end)

return Voice
