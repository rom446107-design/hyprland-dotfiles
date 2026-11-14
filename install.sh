#!/usr/bin/env bash
# Привязывает конфиги из этого репозитория к ~/.config
#
#   ./install.sh
#
# Каталоги hypr, rofi, waybar, kitty, polybar, sptlrx связываются симлинками;
# существующие каталоги, если их нет в репозитории, переименовываются в *.bak.<дата>.
# ~/.Xresources копируется (шрифт/DPI).
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cfg="${XDG_CONFIG_HOME:-$HOME/.config}"
mkdir -p "$cfg"

for name in hypr rofi foot waybar kitty polybar sptlrx; do
    dest="$cfg/$name"
    if [[ -e "$dest" && ! -L "$dest" ]]; then
        backup="$dest.bak.$(date +%Y%m%d-%H%M%S)"
        mv "$dest" "$backup"
        echo "  существующий каталог сохранён как $(basename "$backup")"
    elif [[ -L "$dest" ]]; then
        rm "$dest"
    fi
    ln -s "$root/$name" "$dest"
    echo "  $dest -> $root/$name"
done

# Шрифт/DPI для X11-приложений (xpdf, старые программы)
if [[ -f "$root/Xresources" ]]; then
    cp "$root/Xresources" "$HOME/.Xresources"
    echo "  $HOME/.Xresources обновлён"
fi

echo "Готово: симлинки ~/.config/{hypr,rofi,waybar,kitty,polybar,sptlrx} -> $root созданы"
