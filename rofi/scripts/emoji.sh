#!/usr/bin/env bash
# Поиск эмодзи: выбор копирует эмодзи в буфер обмена.
set -eu

DATA="${XDG_CONFIG_HOME:-$HOME/.config}/rofi/emoji-en-US.json"
if [[ ! -f "$DATA" ]]; then
    notify-send -a "Rofi" "Эмодзи" "Не найден файл $DATA"
    exit 1
fi

selection=$(
    python3 - "$DATA" <<'PY' |
import json, sys

with open(sys.argv[1], encoding="utf-8") as f:
    data = json.load(f)

for emoji, names in data.items():
    print(f"{emoji}   {', '.join(names)}")
PY
        rofi -dmenu -i -p "Эмодзи" \
            -mesg "Enter — скопировать в буфер, Esc — закрыть" \
            -theme-str 'listview { lines: 9; } window { width: 520px; }'
) || exit 0

[[ -n "$selection" ]] || exit 0

emoji=${selection%% *}
printf '%s' "$emoji" | wl-copy
notify-send -a "Rofi" "Эмодзи скопирован" "$emoji"
