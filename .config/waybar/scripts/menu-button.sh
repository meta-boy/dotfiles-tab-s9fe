#!/bin/sh
# Menu button: red with the battery percentage when low and not charging
b=/sys/class/power_supply/battery
cap=$(cat $b/capacity 2>/dev/null || echo 100)
status=$(cat $b/status 2>/dev/null)
if [ "$cap" -le 15 ] && [ "$status" != "Charging" ]; then
    printf '{"text":"\\uf244  %s%%","class":"low"}\n' "$cap"
else
    printf '{"text":"\\uf0c9","class":"normal"}\n'
fi
