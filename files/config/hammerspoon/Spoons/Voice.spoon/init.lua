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

		-- Wait a moment for ffmpeg to finish writing
		hs.timer.doAfter(0.5, function()
			local audioFile = "/tmp/voice.wav"
			local fileInfo = hs.fs.attributes(audioFile)

			if not fileInfo then
				hs.alert.show("ERROR: Audio file not created")
				isRecording = false
				return
			end

			if fileInfo.size < 1000 then
				hs.alert.show("ERROR: Audio file too small")
				isRecording = false
				return
			end

			hs.alert.show("Recording stopped. Transcribing...")

			hs.task
				.new("/etc/profiles/per-user/nhackford/bin/whisper-cli", function(exitCode, stdOut, stdErr)
					if exitCode == 0 then
						local file = io.open("/tmp/voice.txt", "r")
						if file then
							local text = file:read("*all")
							file:close()

							-- Remove trailing newline if present
							text = text:gsub("\n$", "")

							if #text == 0 then
								hs.alert.show("WARNING: Transcription is empty")
							elseif text == "Thank you." or text == "Thank you" then
								hs.alert.show("WARNING: No audio detected")
							else
								hs.eventtap.keyStrokes(text)
							end

							os.execute("rm /tmp/voice.wav /tmp/voice.mp3 /tmp/voice.txt 2>/dev/null")
						else
							hs.alert.show("Failed to read transcription file")
						end
					else
						hs.alert.show("Transcription failed (exit code: " .. exitCode .. ")")
						hs.console.printStyledtext("STDOUT: " .. (stdOut or ""))
						hs.console.printStyledtext("STDERR: " .. (stdErr or ""))
					end
				end, {
					"-m",
					"/Users/nhackford/models/ggml-large-v3-turbo",
					"-l",
					"en",
					"-otxt",
					"-of",
					"/tmp/voice",
					audioFile,
				})
				:start()
		end)

		isRecording = false
	else
		hs.alert.show("Recording started...")

		-- Clean up any old files
		os.execute("rm /tmp/voice.wav /tmp/voice.txt 2>/dev/null")

		-- Get the system's default audio input device dynamically
		local audioDeviceTask = hs.task.new("/opt/homebrew/bin/SwitchAudioSource", function(exitCode, stdOut, stdErr)
			if exitCode ~= 0 then
				hs.alert.show("Failed to detect audio device")
				isRecording = false
				return
			end

			-- Trim whitespace from device name
			local deviceName = stdOut:gsub("^%s*(.-)%s*$", "%1")
			local audioDevice = ":" .. deviceName

			recordingProcess = hs.task
				.new(
					"/etc/profiles/per-user/nhackford/bin/ffmpeg",
					nil,
					{ "-f", "avfoundation", "-i", audioDevice, "-ar", "16000", "/tmp/voice.wav" }
				)
				:start()
		end, { "-t", "input", "-c" })
		audioDeviceTask:start()

		isRecording = true
	end
end)

return Voice
