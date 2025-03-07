local current_id, threshold
Swipe = hs.loadSpoon("Swipe")
Swipe:start(3, function(direction, distance, id)
	if id == current_id then
		if distance > threshold then
			threshold = math.huge -- only trigger once per swipe

			if direction == "left" then
				hs.execute(
					"/run/current-system/sw/bin/aerospace list-workspaces --monitor focused --empty no | /run/current-system/sw/bin/aerospace workspace next"
				)
			elseif direction == "right" then
				hs.execute(
					"/run/current-system/sw/bin/aerospace list-workspaces --monitor focused --empty no | /run/current-system/sw/bin/aerospace workspace prev"
				)
			end
		end
	else
		current_id = id
		threshold = 0.2 -- swipe distance > 20% of trackpad
	end
end)

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
				"/etc/profiles/per-user/nhackford/bin/whisper-cpp",
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
						hs.alert.show("Transcription failed")
						hs.console.printStyledtext(stdErr)
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
