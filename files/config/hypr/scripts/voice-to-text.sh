#!/run/current-system/sw/bin/bash

RECORDING_FLAG="/tmp/voice_recording"
AUDIO_FILE="/tmp/voice.wav"

# Check for required dependencies
check_deps() {
	local missing=()
	command -v ffmpeg >/dev/null || missing+=("ffmpeg")
	command -v moonshine-cli >/dev/null || missing+=("moonshine-cli")
	command -v wl-copy >/dev/null || missing+=("wl-copy")
	command -v hyprctl >/dev/null || missing+=("hyprctl")
	command -v wtype >/dev/null || missing+=("wtype")

	if [[ ${#missing[@]} -gt 0 ]]; then
		notify "Missing dependencies: ${missing[*]}"
		exit 1
	fi
}

# Send notification
notify() {
	local msg="$1"
	notify-send "Voice to Text" "$msg" 2>/dev/null || true
}

# Clean up temp files
cleanup() {
	rm -f "$AUDIO_FILE"
}

# Start recording
start_recording() {
	notify "Recording started..."

	# Record audio in background
	ffmpeg -f pulse -i default -ar 16000 -ac 1 "$AUDIO_FILE" 2>/dev/null &
	local ffmpeg_pid=$!
	echo $ffmpeg_pid >"$RECORDING_FLAG"
}

# Stop recording and transcribe
stop_recording() {
	if [[ ! -f "$RECORDING_FLAG" ]]; then
		notify "No recording in progress"
		exit 1
	fi

	# Kill recording process
	local pid=$(cat "$RECORDING_FLAG")
	kill -TERM "$pid" 2>/dev/null
	sleep 0.5
	wait "$pid" 2>/dev/null
	rm -f "$RECORDING_FLAG"

	notify "Recording stopped. Transcribing..."

	# Check if audio file exists and has content
	if [[ ! -f "$AUDIO_FILE" ]] || [[ ! -s "$AUDIO_FILE" ]]; then
		notify "No audio recorded"
		cleanup
		exit 1
	fi

	# Transcribe with moonshine-cli
	local text
	text=$(moonshine-cli "$AUDIO_FILE" 2>/dev/null)
	if [[ $? -eq 0 ]] && [[ -n "$text" ]]; then
		# Remove trailing whitespace
		text=$(echo "$text" | sed 's/[[:space:]]*$//')
		notify "Transcription complete. Typing text..."

		# Copy to clipboard and type text
		echo "$text" | wl-copy
		sleep 0.1
		# Escape spaces for wtype (fixes Chromium/Electron apps)
		# Ghostty doesn't need escaping
		local window_class=$(hyprctl activewindow -j | jq -r '.class')
		case "$window_class" in
		com.mitchellh.ghostty)
			wtype "$text"
			;;
		*)
			local escaped_text="${text// /\\ }"
			wtype "$escaped_text"
			;;
		esac
		notify "Text typed successfully"
	else
		notify "Transcription failed"
	fi

	cleanup
}

# Main logic
main() {
	check_deps

	if [[ -f "$RECORDING_FLAG" ]]; then
		stop_recording
	else
		start_recording
	fi
}

# Handle cleanup on script exit
trap cleanup EXIT

main "$@"
