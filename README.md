# dotfiles — Hyprland + Rofi + Waybar

Мониторинговая установка для ноутбука 1366×768:

- **Hyprland** (`hypr/hyprland.lua`) — конфиг на Lua (не hyprlang), окна, клавиши, blur.
- **Rofi** (`rofi/`) — лаунчер, меню обоев (`Super+Shift+W`), эмодзи (`Super+.`), питание (`Super+Shift+P`).
- **Waybar** (`waybar/`) — грей-бар: воркспейсы, раскладка, часы, звук, сеть, батареи и т.д.
- Тема оформления графитовая: фон `#181818`, текст `#e6e6e6`, акцент `#9a9a9a`.

## Установка

```bash
git clone https://github.com/<username>/dotfiles.git
cd dotfiles
./install.sh
```

`install.sh` создаёт симлинки `~/.config/{hypr,rofi,waybar}` на каталоги этого репозитория.

## Программы

- swaybg — обои;
- foot — терминал (используется в Waybar для сети);
- power-profiles-daemon, brightnessctl, playerctl, pavucontrol, nmcli/nmtui;
- rofi, waybar, hyprland.
