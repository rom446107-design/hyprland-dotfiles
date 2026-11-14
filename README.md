<p align="center">
    <img src=".github/bar.png" alt="Waybar" width="640"/><br/>
    <img src=".github/rofi.png" alt="Rofi" width="320"/>
    <img src=".github/keybinds.png" alt="Окно хоткеев" width="320"/>
</p>

<p align="center">
    <img src=".github/desktop.png" alt="Рабочий стол" width="640"/>
</p>

# hyprland-dotfiles · Hyprland + Rofi + Waybar

Лёгкая графитовая конфигурация рабочего стола на **CachyOS** для ноутбука 1366×768.
Палитра: тёмный фон `#181818`, текст `#e6e6e6`, акцент `#9a9a9a` — те же оттенки используются в **Hyprland** (рамки окон), **Rofi**, **Waybar** и в меню на базе Rofi.

## Состав

| Компонент           | Файл                        | Что внутри |
|----------------------|-----------------------------|------------|
| Hyprland 0.56+       | `hypr/hyprland.lua`         | конфиг **на Lua** (не hyprlang): мониторы, окна, воркспейсы, бинды, blur |
| Rofi                 | `rofi/config.rasi`<br>`rofi/themes/graphite.rasi` | лаунчер приложений, меню обоев (с превью), эмодзи, хоткеи, питание в одной теме |
| Waybar               | `waybar/config.jsonc`<br>`waybar/style.css` | воркспейсы, раскладка, часы, звук, сеть, приватность, питание, яркость, батарея |
| Kitty                | `kitty/kitty.conf`          | основной терминал: палитра `#e6e6e6` на `#181818`, прозрачность 0.88, cursor trail |
| Polybar              | `polybar/config.ini`<br>`polybar/launch.sh` | X11-бар (остался с bspwm-времён): CPU, память, температура, звук, яркость, батарея, плеер |
| sptlrx               | `sptlrx/config.yaml`        | текст песен Spotify (MPRIS): графитовая стилизация, режим «эстетик» через `~/.local/bin/lyrics` |
| Xresources           | `Xresources`                | DPI/шрифт для X11-приложений (копируется в `~/.Xresources`) |
| Установка            | `install.sh`                | симлинки `~/.config/{hypr,rofi,foot,waybar,kitty,polybar,sptlrx}` → этот репозиторий |

## Горячие клавиши

- `Super + D` ↦ приложения (rofi drun)
- `Super + Shift + W` ↦ сменить обои (окно с превью картинок)
- `Super + .` ↦ эмодзи (копирование в буфер)
- `Super + Shift + L` ↦ текст песен (sptlrx, «эстетик»-режим)
- `Super + Shift + /` ↦ окно со всеми хоткеями (живой список из `hyprctl binds`, русские описания)
- `Super + Shift + P` ↦ меню питания: выключить / перезагрузить / спящий режим / выйти

## Установка

```bash
git clone https://github.com/rom446107-design/hyprland-dotfiles.git
cd hyprland-dotfiles
./install.sh
```

`install.sh` привязывает каталоги репозитория к `~/.config` симлинками и сохраняет
существующие конфиги как `~/.config/<name>.bak.<время>`.
После этого достаточно перезапустить Hyprland.

## Программы

| Пакет                   | Зачем |
|--------------------------|-------|
| `hyprland`              | композитор (Wayland) |
| `waybar`, `rofi`        | бар и лаунчер |
| `swaybg`                | обои |
| `kitty`                 | основной терминал (тема в `kitty/kitty.conf`) |
| `polybar`               | X11-бар (опционально, для сессий bspwm/X11) |
| `sptlrx`                | текст песен Spotify по MPRIS |
| `power-profiles-daemon` | управление профилями питания |
| `brightnessctl`         | регулировка яркости |
| `pavucontrol`           | GUI для Pipewire-звука |
| `nmcli`, `nmtui`        | управление сетью |
| `wl-copy`               | буфер обмена (для эмодзи) |
| `notify-send`           | уведомления при смене обоев |

## Настройка

- Палитра задаётся в трёх местах, чтобы всё менялось синхронно:
  `rofi/themes/graphite.rasi`, `waybar/style.css`, `kitty/kitty.conf`, `sptlrx/config.yaml`
  и `hypr/hyprland.lua` (цвета рамок окон).
- Скрипты меню (`rofi/scripts/*.sh`) — самостоятельные, других зависимостей в репозитории нет.
- При добавлении нового модуля в `waybar/config.jsonc` добавь его стиль в `waybar/style.css` (id вида `#language`).
- Обои меняются через `Super + Shift + W`; последний выбор сохраняется в `~/.local/state/rofi-wallpaper` и восстанавливается при следующем входе.
- Меню обоев показывает миниатюры картинок через `-preview-cmd` (rofi сам не умеет превью файлов).
- Окно хоткеев (`Super + Shift + /`) читает бинды на лету из `hyprctl binds -j` — новые бинды появятся в нём без правки скрипта; описания известных биндов задаются таблицей `DESC` внутри `rofi/scripts/keybinds.sh`.
- «Эстетик»-режим лирики: скрипт `~/.local/bin/lyrics` (не входит в репозиторий) запускает `sptlrx` в kitty с плавающей полупрозрачной геометрией — размер/центр задаёт правило `lyrics-float` в `hypr/hyprland.lua`.

## Лицензия

MIT — см. файл [LICENSE](./LICENSE).
