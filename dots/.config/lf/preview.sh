#!/usr/bin/env bash
file=$1
w=$2
h=$3
x=$4
y=$5

# case "$1" in
# 	*.tgz|*.tar.gz) tar tzf "$1";;
# 	*.tar.bz2|*.tbz2) tar tjf "$1";;
# 	*.tar.txz|*.txz) xz --list "$1";;
# 	*.tar) tar tf "$1";;
# 	*.zip|*.jar|*.war|*.ear|*.oxt) unzip -l "$1";;
# 	*.rar) unrar l "$1";;
# 	*.7z) 7z l "$1";;
# 	*.[1-8]) man "$1" | col -b ;;
# 	*.o) nm "$1" | less ;;
# 	*.torrent) transmission-show "$1";;
# 	*.iso) iso-info --no-header -l "$1";;
# 	*odt,*.ods,*.odp,*.sxw) odt2txt "$1";;
# 	*.doc) catdoc "$1" ;;
# 	*.docx) docx2txt "$1" - ;;
# 	*.csv) cat "$1" | sed s/,/\\n/g ;;
# 	*.pdf)
# 		CACHE=$(mktemp /tmp/thumbcache.XXXXX)
# 		pdftoppm -png -f 1 -singlefile "$1" "$CACHE"
# 		$HOME/.config/lf/image draw "$CACHE.png" $num 1 $numb $numc
# 		;;
# 	*.epub)
# 		CACHE=$(mktemp /tmp/thumbcache.XXXXX)
# 		epub-thumbnailer "$1" "$CACHE" 1024
# 		$HOME/.config/lf/image draw "$CACHE" $num 1 $numb $numc
# 		;;
# 	*.bmp|*.jpg|*.jpeg|*.png|*.xpm)
# 		$HOME/.config/lf/image draw "$1" $num 1 $numb $numc
# 		;;
# 	*.wav|*.mp3|*.flac|*.m4a|*.wma|*.ape|*.ac3|*.og[agx]|*.spx|*.opus|*.as[fx]|*.flac) exiftool "$1";;
# 	*.avi|*.mp4|*.wmv|*.dat|*.3gp|*.ogv|*.mkv|*.mpg|*.mpeg|*.vob|*.fl[icv]|*.m2v|*.mov|*.webm|*.ts|*.mts|*.m4v|*.r[am]|*.qt|*.divx)
# 		CACHE=$(mktemp /tmp/thumbcache.XXXXX)
# 		ffmpegthumbnailer -i "$1" -o "$CACHE" -s 0
# 		$HOME/.config/lf/image draw "$CACHE" $num 1 $numb $numc
# 		;;
# 	*) highlight --out-format ansi "$1" || cat "$1";;
# esac

if [[ "$( file -Lb --mime-type "$file")" =~ ^image ]]; then
    kitty +kitten icat --silent --stdin no --transfer-mode file --place "${w}x${h}@${x}x${y}" "$file" < /dev/null > /dev/tty
    # wezterm imgcat "$file" > /dev/tty
    # chafa "$1" -f symbols -s "$geometry" --animate false > /dev/tty
    exit 1
fi

# pistol "$file"
