#!/usr/bin/env bash
# Окно со всеми хоткеями Hyprland с человеческими описаниями.
# Описания известным биндам задаёт таблица DESC ниже;
# незнакомые выводятся в понятном виде (диспатчер + аргумент).
set -euo pipefail

python3 <<'PY' | rofi -dmenu -i -p "Хоткеи Hyprland" \
    -mesg "Живой список из hyprctl binds · Esc — закрыть" \
    -theme-str '* { font: "JetBrainsMono Nerd Font 9"; } listview { lines: 11; } window { width: 520px; }' >/dev/null || true

import json
import subprocess

# ── Человеческие описания: (modmask, клавиша) → текст ────────
# modmask: SUPER=64, SHIFT=1, CTRL=4, ALT=8
DESC = {
    (64, "q"):      "Открыть терминал (kitty)",
    (64, "c"):      "Закрыть активное окно",
    (64, "m"):      "Выход из Hyprland",
    (64, "e"):      "Файловый менеджер (thunar)",
    (64, "v"):      "Плавающее окно вкл/выкл",
    (64, "d"):      "Лончер приложений (rofi)",
    (64, "p"):      "Pseudo-тайлинг окна",
    (64, "j"):      "Сменить направление сплита",
    (64, "left"):   "Фокус влево",
    (64, "right"):  "Фокус вправо",
    (64, "up"):     "Фокус вверх",
    (64, "down"):   "Фокус вниз",
    (65, "left"):   "Поменять окно местами с левым",
    (65, "right"):  "Поменять окно местами с правым",
    (65, "up"):     "Поменять окно местами с верхним",
    (65, "down"):   "Поменять окно местами с нижним",
    (68, "left"):   "Переместить окно влево",
    (68, "right"):  "Переместить окно вправо",
    (68, "up"):     "Переместить окно вверх",
    (68, "down"):   "Переместить окно вниз",
    (64, "s"):      "Показать/скрыть scratchpad (special:magic)",
    (65, "s"):      "Спрятать окно в scratchpad",
    (64, "w"):      "Меню обоев (rofi)",
    (65, "w"):      "Меню обоев (rofi)",
    (64, "period"): "Меню эмодзи",
    (65, "p"):      "Меню питания",
    (65, "l"):      "Текст песен (sptlrx)",
    (65, "slash"):  "Все хоткеи Hyprland (это окно)",
    (0, "xf86audiomute"):        "Звук: включить/выключить",
    (0, "xf86audiomicmute"):     "Микрофон: включить/выключить",
    (0, "xf86monbrightnessup"):  "Яркость экрана +",
    (0, "xf86monbrightnessdown"):"Яркость экрана −",
    (0, "xf86audionext"):        "Следующий трек",
    (0, "xf86audioplay"):        "Трек: играть/пауза",
    (0, "xf86audiopause"):       "Трек: играть/пауза",
    (0, "xf86audioprev"):        "Предыдущий трек",
    # мышь
    (64, "mouse272"): "Перетащить окно (Super+ЛКМ)",
    (64, "mouse273"): "Изменить размер окна (Super+ПКМ)",
    (64, "mouseup"):  "Прокрутка: рабочий стол вперёд",
    (64, "mousedown"):"Прокрутка: рабочий стол назад",
}

# Понятные имена диспатчеров на случай незнакомых биндов
DISPATCH = {
    "exec_cmd": "запустить",
    "window.close": "закрыть окно",
    "window.float": "плавающее окно",
    "window.pseudo": "pseudo-тайлинг",
    "window.drag": "перетащить окно",
    "window.resize": "изменить размер окна",
    "window.move": "переместить окно",
    "window.swap": "поменять окна местами",
    "window.fullscreen": "полноэкранный режим",
    "focus": "фокус",
    "layout": "раскладка",
    "workspace": "рабочий стол",
    "workspace.toggle_special": "scratchpad",
    "exit": "выход",
}

def modname(m):
    if not m:
        return ""
    parts = []
    if m & 64:
        parts.append("Super")
    if m & 1:
        parts.append("Shift")
    if m & 4:
        parts.append("Ctrl")
    if m & 8:
        parts.append("Alt")
    if m & 128:
        parts.append("Mod5")
    return "+".join(parts)

# Понятные имена клавиш
KEY_NAMES = {
    "left": "←", "right": "→", "up": "↑", "down": "↓",
    "slash": "/", "period": ".", "comma": ",",
    "bracketleft": "[", "bracketright": "]", "grave": "`",
    "space": "Пробел", "return": "Enter", "escape": "Esc", "tab": "Tab",
    "mouse272": "ЛКМ", "mouse273": "ПКМ", "mouse274": "СКМ",
    "mouse4": "Колесо↑", "mouse5": "Колесо↓",
    "xf86audiomute": "Vol✕", "xf86audiomicmute": "Mic✕",
    "xf86audioraisevolume": "Vol+", "xf86audiolowervolume": "Vol−",
    "xf86monbrightnessup": "Ярк+", "xf86monbrightnessdown": "Ярк−",
    "xf86audionext": "Трек▶▶", "xf86audioprev": "Трек◀◀",
    "xf86audioplay": "Трек▶/⏸", "xf86audiopause": "Трек▶/⏸",
}

out = subprocess.run(["hyprctl", "binds", "-j"], capture_output=True, text=True)
binds = json.loads(out.stdout)

lines = []
for b in binds:
    mod = modname(b["modmask"])

    # Клавиша/кнопка
    if b.get("mouse"):
        key = f"mouse{b['keycode']}"
    elif b["key"]:
        key = b["key"]
    else:
        key = f"code:{b['keycode']}"
    combo = f"{mod}+{key}" if mod else key

    # Описание: из таблицы, иначе — расшифровка диспатчера
    key_l = key.lower()
    desc = DESC.get((b["modmask"], key_l))
    if desc is None and b["modmask"] in (64, 65) and key_l.isdigit():
        # Super+цифра / Super+Shift+цифра → рабочие столы
        ws = int(key_l) % 10 or 10
        desc = (f"Перейти на рабочий стол {ws}" if b["modmask"] == 64
                else f"Перенести окно на рабочий стол {ws}")
    if desc is None:
        disp = b["dispatcher"]
        verb = disp.split("(")[1].rstrip(")") if "(" in disp else disp
        arg = b["arg"] or ""
        human = DISPATCH.get(verb, verb)
        if arg:
            desc = f"{human}: {arg}"
        else:
            desc = human

    submap = b.get("submap") or ""
    prefix = f"[{submap}] " if submap else ""
    shown_key = KEY_NAMES.get(key_l, key)
    shown = f"{mod}+{shown_key}" if mod else shown_key
    lines.append(f"{shown:<26} {desc}")

print("\n".join(sorted(set(lines))))
PY
