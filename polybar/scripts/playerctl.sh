#!/usr/bin/env bash
# Вывод для polybar: иконка статуса + название трека
# (шаблон playerctl 2.4 не умеет тернарник, поэтому статус через case)

status=$(playerctl status 2>/dev/null) || exit 0
title=$(playerctl metadata --format '{{ title }}' 2>/dev/null) || exit 0

case "$status" in
    Playing) printf '\uf04b %s' "$title" ;;
    Paused)  printf '\uf04c %s' "$title" ;;
    *)       exit 0 ;;
esac
