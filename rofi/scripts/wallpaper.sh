#!/usr/bin/env bash
# Обои через Rofi (swaybg): выбор картинки + запоминание последнего выбора.
#   wallpaper.sh             — открыть меню
#   wallpaper.sh --restore   — восстановить последние обои (для автозапуска)
set -euo pipefail

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}"
STATE_FILE="$STATE_DIR/rofi-wallpaper"

if [[ "${1:-}" == "--restore" ]]; then
    if [[ -f "$STATE_FILE" ]]; then
        last=$(<"$STATE_FILE")
        if [[ -f "$last" ]]; then
            pkill -x swaybg 2>/dev/null || true
            setsid swaybg -i "$last" -m fill >/dev/null 2>&1 &
        fi
    fi
    exit 0
fi

readarray -t files < <(
    find \
        "$HOME/Wallpapers" \
        "$HOME/Изображения" \
        "$HOME/Pictures" \
        "$HOME/Загрузки" \
        /usr/share/backgrounds \
        -maxdepth 3 -type f \
        \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) \
        2>/dev/null | sort -u
)

if (( ${#files[@]} == 0 )); then
    notify-send -a "Rofi" "Обои" "Не найдено изображений в ~/Изображения, ~/Wallpapers, ~/Pictures, ~/Загрузки" 2>/dev/null || true
    exit 0
fi

# Уникальные подписи: <имя файла без расширения>, дубликаты нумеруются.
declare -A seen=()
declare -A paths=()
items=()
for f in "${files[@]}"; do
    base=$(basename -- "$f")
    base=${base%.*}
    label=$base
    n=1
    while [[ -n "${seen[$label]:-}" ]]; do
        n=$((n + 1))
        label="$base ($n)"
    done
    seen[$label]=1
    paths[$label]=$f
    items+=("$label")
done

choice=$(
    printf '%s\n' "${items[@]}" |
        rofi -dmenu -i -p "Обои" \
            -mesg "Enter — применить, Esc — отмена" \
            -theme-str 'window { width: 720px; } listview { lines: 8; } element-icon { size: 96px; } element { padding: 6px; }'
) || exit 0

[[ -n "$choice" && -n "${paths[$choice]:-}" ]] || exit 0

path=${paths[$choice]}
mkdir -p "$STATE_DIR"
printf '%s\n' "$path" >"$STATE_FILE"

pkill -x swaybg 2>/dev/null || true
setsid swaybg -i "$path" -m fill >/dev/null 2>&1 &
