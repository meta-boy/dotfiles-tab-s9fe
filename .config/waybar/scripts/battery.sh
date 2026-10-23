#!/bin/sh
# The tablet's battery from sysfs; icon and colour by level, bolt while charging
b=/sys/class/power_supply/battery
cap=$(cat $b/capacity 2>/dev/null || echo 0)
status=$(cat $b/status 2>/dev/null)
if   [ "$cap" -ge 80 ]; then icon='\uf240'
elif [ "$cap" -ge 55 ]; then icon='\uf241'
elif [ "$cap" -ge 30 ]; then icon='\uf242'
elif [ "$cap" -ge 10 ]; then icon='\uf243'
else                         icon='\uf244'; fi
if   [ "$cap" -le 20 ]; then class=low
elif [ "$cap" -le 50 ]; then class=half
else                         class=ok; fi
bolt=''; [ "$status" = Charging ] && bolt=" <span color='#f9e2af'>\\uf0e7</span>"
printf '{"text":"%s  %s%%%s","class":"%s","tooltip":"Battery %s%% · %s"}\n' "$icon" "$cap" "$bolt" "$class" "$cap" "$status"
