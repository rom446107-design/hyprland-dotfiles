#!/usr/bin/env bash
# Обои через Rofi: выбор картинки + запоминание последнего выбора.
#   wallpaper.sh             — открыть меню
#   wallpaper.sh --restore   — восстановить последние обои (для автозапуска)
#
# Установка обоев: swaybg под Wayland (Hyprland), feh под X11 (bspwm).
# Вид окна — как у всех остальных: тема graphite из config.rasi, без переопределений.
set -euo pipefail

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}"
STATE_FILE="$STATE_DIR/rofi-wallpaper"

apply_wallpaper() {
    if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
        # Wayland
        if ! command -v swaybg >/dev/null; then
            notify-send -a "Rofi" "Обои" "Не найден swaybg" 2>/dev/null || true
            return 1
        fi
        pkill -x swaybg 2>/dev/null || true
        setsid swaybg -i "$1" -m fill >/dev/null 2>&1 &
    else
        # X11 (bspwm)
        if ! command -v feh >/dev/null; then
            notify-send -a "Rofi" "Обои" "Не найден feh — установите: sudo pacman -S feh" 2>/dev/null || true
            return 1
        fi
        feh --bg-fill "$1"
    fi
}

if [[ "${1:-}" == "--restore" ]]; then
    if [[ -f "$STATE_FILE" ]]; then
        last=$(<"$STATE_FILE")
        if [[ -f "$last" ]]; then
            apply_wallpaper "$last"
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

# Превью: rofi зовёт preview-cmd с текстом строки и ждёт путь к картинке
mapfile=$(mktemp)
preview=$(mktemp)
trap 'rm -f "$mapfile" "$preview"' EXIT
: >"$mapfile"
for label in "${!paths[@]}"; do
    printf '%s\t%s\n' "$label" "${paths[$label]}" >>"$mapfile"
done
cat >"$preview" <<EOF
#!/bin/sh
awk -F'\t' -v l="\$1" '\$1 == l {print \$2; exit}' "$mapfile" || true
EOF
chmod +x "$preview"

# Вид окна идентичен остальным, но с превью обоев
choice=$(
    printf '%s\n' "${items[@]}" |
        rofi -dmenu -i -p "Обои" \
            -mesg "Enter — применить, Esc — отмена" \
            -preview-cmd "$preview" \
            -theme-str 'window { width: 500px; } listview { lines: 6; } element-icon { size: 56px; } element { padding: 4px; spacing: 10px; }'
) || exit 0

[[ -n "$choice" && -n "${paths[$choice]:-}" ]] || exit 0

path=${paths[$choice]}
mkdir -p "$STATE_DIR"
printf '%s\n' "$path" >"$STATE_FILE"

apply_wallpaper "$path"
