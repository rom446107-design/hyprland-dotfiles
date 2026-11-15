#!/usr/bin/env bash
# Wi-Fi через Rofi: подключение к сетям, отключение, вкл/выкл радиомодуля.
#   wifi.sh          — открыть меню
# Зависимости: nmcli (NetworkManager), rofi, notify-send.
# Список сетей идёт из nmcli; пароль спрашивается только если сеть ещё не сохранена.
set -euo pipefail

LOCK=$'\uf023'   # замок (сеть с паролем)
OFF=$'\uf205'    # тумблер «выключить»
UNLINK=$'\uf127' # разорвать связь

# ── Состояние ──────────────────────────────────────────────
DEV=$(nmcli -t -f DEVICE,TYPE device status | awk -F: '$2 == "wifi" { print $1; exit }')
if [[ -z "$DEV" ]]; then
    notify-send -a "Rofi" "Wi-Fi" "Wi-Fi адаптер не найден"
    exit 1
fi

WIFI_ON=$(nmcli radio wifi)
CURRENT=$(nmcli -t -f ACTIVE,TYPE,NAME connection show --active |
          awk -F: '$1 == "да" && $2 == "802-11-wireless" { print $3; exit }')

# ── Список сетей (обновить кэш сканирования) ───────────────
nmcli device wifi rescan >/dev/null 2>&1 || true
sleep 1

# ── Формирование меню ──────────────────────────────────────
menu=$(python3 - "$WIFI_ON" "$CURRENT" <<'PY'
import subprocess, sys

wifi_on, current = sys.argv[1], sys.argv[2]
lines = []

if wifi_on != "enabled":
    print("\uf011  Включить Wi-Fi")
    sys.exit(0)

lines.append("\uf011  Выключить Wi-Fi")
if current:
    lines.append(f"\uf127  Отключиться от {current}")

raw = subprocess.run(
    ["nmcli", "-g", "IN-USE,SSID,SIGNAL,SECURITY", "device", "wifi", "list"],
    capture_output=True, text=True).stdout

best = {}  # ssid → (signal, security) — SSID с несколькими точками: оставляем самую сильную
for line in raw.splitlines():
    parts = line.split(":")
    if len(parts) < 4:
        continue
    ssid = parts[1].strip()
    if not ssid:
        continue
    try:
        signal = int(parts[2])
    except ValueError:
        continue
    sec = "*" in parts[3]
    if ssid not in best or signal > best[ssid][0]:
        best[ssid] = (signal, sec)

for ssid, (signal, sec) in sorted(best.items(), key=lambda kv: -kv[1][0]):
    mark = " \u2714" if ssid == current else ""
    lock = " \uf023" if sec else ""
    lines.append(f"{ssid}   {signal}%{lock}{mark}")

print("\n".join(lines))
PY
) || exit 0

choice=$(printf '%s\n' "$menu" |
    rofi -dmenu -i -p "Wi-Fi" \
        -mesg "Wi-Fi: вкл · Сеть: ${CURRENT:-нет} · Esc — закрыть" \
        -theme-str 'mainbox { children: [listview, message]; } listview { lines: 9; } window { width: 520px; }'
) || exit 0

[[ -n "$choice" ]] || exit 0

# ── Действия ───────────────────────────────────────────────
case "$choice" in
    *$'\uf011'*)  # вкл/выкл радиомодуль
        if [[ "$WIFI_ON" == "enabled" ]]; then
            nmcli radio wifi off
            notify-send -a "Rofi" "Wi-Fi" "Радиомодуль выключен"
        else
            nmcli radio wifi on
            notify-send -a "Rofi" "Wi-Fi" "Радиомодуль включён"
        fi
        exit 0 ;;
    *$'\uf127'*)  # отключиться от текущей сети
        nmcli device disconnect "$DEV"
        notify-send -a "Rofi" "Wi-Fi" "Отключено"
        exit 0 ;;
esac

# Сеть: «SSID   74% [🔒] [✔]» → SSID до трёх пробелов
ssid=${choice%%   *}

connect() {  # $1 = пароль или пусто
    if [[ -n "$1" ]]; then
        nmcli device wifi connect "$ssid" password "$1"
    else
        nmcli device wifi connect "$ssid"
    fi
}

if out=$(connect "" 2>&1); then
    notify-send -a "Rofi" "Wi-Fi" "Подключено: $ssid"
else
    # Не хватило сохранённых ключей — спросить пароль
    pass=$(rofi -dmenu -password -p "Пароль · $ssid") || pass=""
    if [[ -n "$pass" ]] && connect "$pass"; then
        notify-send -a "Rofi" "Wi-Fi" "Подключено: $ssid"
    else
        notify-send -a "Rofi" "Wi-Fi" "Не удалось подключиться к $ssid"
    fi
fi
