#!/bin/sh
# Запуск polybar для bspwm

# Завершаем старые экземпляры (актуально при перезапуске bspwm)
killall -q polybar
while pgrep -x polybar >/dev/null 2>&1; do
    sleep 0.5
done

# Монитор: первый активный (для ноутбука — eDP-1)
MONITOR=$(polybar --list-monitors 2>/dev/null | awk -F: '{print $1; exit}')

echo "polybar: запуск на мониторе ${MONITOR:-eDP-1}" >&2
MONITOR="$MONITOR" polybar --reload main &
