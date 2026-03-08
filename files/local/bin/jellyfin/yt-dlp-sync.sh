#!/usr/bin/env bash
set -euo pipefail

MEDIA_ROOT="/run/media/nick/Passport/Videos/Shows"

# Check that the drive is mounted
if ! mountpoint -q /run/media/nick/Passport; then
	echo "ERROR: Passport drive is not mounted, skipping sync"
	exit 1
fi

# format: "url|directory_name" (channels or playlists)
CHANNELS=(
	"https://www.youtube.com/@msrachel|Ms. Rachel"
	"https://www.youtube.com/@DannyGo|Danny Go"
	"https://youtube.com/playlist?list=PLZS3MUjYqjUGa09r5Y7SXuEcJ13e6-DVt|Smile and Learn - Math"
	"https://youtube.com/playlist?list=PLZS3MUjYqjUHCxHJUnzMsxwKyPyNXR3Fm|Smile and Learn - Yoga"
	"https://youtube.com/playlist?list=PLZS3MUjYqjUGm4h4nBLgn3HGZubVTJ1NS|Smile and Learn - Alphabet"
	"https://youtube.com/playlist?list=PLZS3MUjYqjUEdir2JmYEmcoPjLPD0izDI|Smile and Learn - STEM"
)

for entry in "${CHANNELS[@]}"; do
	IFS='|' read -r url name <<<"$entry"
	dir="$MEDIA_ROOT/$name"

	echo "$(date '+%Y-%m-%d %H:%M:%S') Syncing: $name"

	if [ ! -d "$dir" ]; then
		echo "  Creating directory: $dir"
		mkdir -p "$dir"
	fi

	yt-dlp \
		--download-archive "$dir/downloaded.txt" \
		-f "bestvideo[height<=1080]+bestaudio/best[height<=1080]" \
		-o "$dir/%(title)s.%(ext)s" \
		--write-thumbnail \
		--no-progress \
		--newline \
		"$url" || echo "  WARNING: yt-dlp exited with error for $name (may be partial)"

	echo "$(date '+%Y-%m-%d %H:%M:%S') Done: $name"
	echo ""
done

echo "$(date '+%Y-%m-%d %H:%M:%S') Sync complete"
