#!/usr/bin/env bash
# Привязывает конфиги из этого репозитория к ~/.config
#
#   ./install.sh
#
# Каталоги hypr, rofi, waybar связываются симлинками; существующие
# каталоги, если их нет в репозитории, переименовываются в *.bak.<дата>.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cfg="${XDG_CONFIG_HOME:-$HOME/.config}"
mkdir -p "$cfg"

for name in hypr rofi foot waybar; do
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

echo "Готово: симлинки ~/.config/{hypr,rofi,waybar} -> $root созданы"
