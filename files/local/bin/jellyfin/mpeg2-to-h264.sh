#!/usr/bin/env bash
set -euo pipefail

if [ $# -eq 0 ]; then
	echo "Usage: mpeg2-to-h264.sh <file.mkv> [file2.mkv ...]"
	exit 1
fi

converted=0
failed=0
skipped=0

for file in "$@"; do
	if [ ! -f "$file" ]; then
		echo "SKIP (not found): $file"
		skipped=$((skipped + 1))
		continue
	fi

	if [ -f "${file}.bak" ]; then
		echo "SKIP (already converted): $file"
		skipped=$((skipped + 1))
		continue
	fi

	codec=$(ffprobe -v quiet -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$file" 2>/dev/null | head -1)

	case "$codec" in
	mpeg2video | mpeg4) ;;
	*)
		echo "SKIP (already $codec): $file"
		skipped=$((skipped + 1))
		continue
		;;
	esac

	echo ""
	echo "$(date '+%H:%M:%S') Converting ($codec -> h264): $file"
	mv "$file" "${file}.bak"

	logfile="${file}.log"
	if ffmpeg \
		-fflags +genpts \
		-i "${file}.bak" \
		-c:v libx264 -crf 18 -preset slow \
		-c:a aac -b:a 256k \
		-map 0:v:0 -map 0:a:0 \
		-y "$file" 2>"$logfile"; then
		echo "$(date '+%H:%M:%S') OK: $file"
		rm -f "$logfile"
		converted=$((converted + 1))
	else
		echo "$(date '+%H:%M:%S') FAILED: $file -- restoring backup (see $logfile)"
		mv "${file}.bak" "$file"
		failed=$((failed + 1))
	fi
done

echo ""
echo "$(date '+%H:%M:%S') Done: $converted converted, $skipped skipped, $failed failed"
