#!/usr/bin/env bash
# Меню питания для Rofi
set -euo pipefail

choice=$(
    printf '\uf011   Выключить\n\uf021   Перезагрузить\n\uf186   Спящий режим\n\uf08b   Выйти из сеанса\n' |
        rofi -dmenu -i -p "Питание" \
            -mesg "Enter — выполнить, Esc — отмена" \
            -theme-str 'listview { lines: 4; } window { width: 380px; } inputbar { padding: 10px 14px; }'
) || exit 0

case "$choice" in
    *Выключить*)     systemctl poweroff ;;
    *Перезагрузить*) systemctl reboot ;;
    *Спящий*)        systemctl suspend ;;
    *Выйти*)         hyprctl dispatch exit ;;
esac
