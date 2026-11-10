#!/usr/bin/env bash
# Спектр-визуализация музыки в Waybar: cava снимает монитор пульса
# (всё, что играется в системе) и рисует юникод-бары.
# Вывод — поток JSON-строк для модуля custom/cava (return-type: json).
set -euo pipefail

CONF_DIR="${XDG_RUNTIME_DIR:-/tmp}/waybar-cava"
mkdir -p "$CONF_DIR"
CONF="$CONF_DIR/cava.conf"

# Конфиг cava: столько баров, сколько "влепим" в бар; ре-генерим при старте
cat > "$CONF" <<'EOF'
[input]
method = pulse
[general]
bars = 12
sensitivity = 55
autosens = 1
framerate = 25
[output]
method = raw
data_format = ascii
ascii_max_range = 8
bar_delimiter = 59
frame_delimiter = 10
[smoothing]
noise_reduction = 60
EOF

BARS="▁▂▃▄▅▆▇█"
FIGLETS=("▁▁▁▁▁▁▁▁▁▁▁▁" "")

frame=0
track=""
# cava умирает вместе с баром (restart-interval в конфиге Waybar перезапустит)
cava -p "$CONF" 2>/dev/null | while IFS= read -r line; do
    bars=""
    IFS=';' read -r -a vals <<< "$line"
    for v in "${vals[@]:0:12}"; do
        if [[ "$v" =~ ^[0-9]+$ ]]; then
            (( v > 7 )) && v=7
            bars+="${BARS:v:1}"
        fi
    done
    # подпись трека обновляем редко — раз в ~2 с (25 fps)
    if (( frame % 50 == 0 )); then
        track=$(playerctl metadata --format '{{artist}} — {{title}}' 2>/dev/null || true)
        [[ -n "$track" ]] || track="Тишина: ничего не играет"
    fi
    frame=$((frame + 1))
    printf '{"text": "%s", "tooltip": "музыка: %s"}\n' "$bars" "$track"
done
