#!/usr/bin/env bash
# Меню питания для Rofi — крупные значки в горизонтальный ряд
set -euo pipefail

choice=$(
    printf '\uf011\n\uf021\n\uf186\n\uf08b\n' |
        rofi -dmenu -i -p "Питание" \
            -mesg "Enter — выполнить, Esc — отмена" \
            -theme-str '
mainbox   { children: [listview, message]; spacing: 12px; }
window    { width: 500px; }
listview  { lines: 1; columns: 4; spacing: 8px; fixed-height: false; scrollbar: false; }
element   { children: [element-text]; padding: 24px 0px; border-radius: 14px; }
element-text {
    font:             "JetBrainsMono Nerd Font 30";
    vertical-align:   0.5;
    horizontal-align: 0.5;
}
element selected.normal { background-color: @accent-dim; }
'
) || exit 0

case "$choice" in
    *$'\uf011'*)     systemctl poweroff ;;
    *$'\uf021'*)     systemctl reboot ;;
    *$'\uf186'*)     systemctl suspend ;;
    *$'\uf08b'*)     # Выход: shim не знает диспетчер «exit», нужен Lua-вызов
        if command -v hyprshutdown >/dev/null 2>&1; then
            hyprshutdown
        else
            hyprctl dispatch 'hl.dsp.exit()'
        fi ;;
esac
