#!/bin/sh
# Status menu under the bar's right edge (Hyprland port of the Quickshell/rofi one)
pkill -x rofi && exit 0
b=/sys/class/power_supply/battery; bc=$(cat $b/capacity); bs=$(cat $b/status)
ip=$(ip -4 -o addr show wlan0 2>/dev/null | awk '{print $4}' | cut -d/ -f1); [ -n "$ip" ] || ip="disconnected"
snd=$(timeout 0.4 pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null; timeout 0.2 pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null)
vol=$(printf '%s' "$snd" | grep -o '[0-9]*%' | head -1)
printf '%s' "$snd" | grep -q "Mute: yes" && vol="muted"
up=$(uptime -p | sed 's/^up //')
choice=$(printf '%s\n' \
  "  $(date '+%A %d %B %Y')" \
  "  $(date '+%-I:%M %p')" \
  "  Battery  $bc% · $bs" \
  "  Wi-Fi  $ip" \
  "  Volume  ${vol:-n/a}" \
  "  Uptime  $up" \
  "  Volume up" \
  "  Volume down" \
  "  Toggle mute" \
  "  Screenshot" \
  "  Reload Hyprland" \
  "  Log out" \
  | rofi -dmenu -i -theme ~/.config/rofi/menu.rasi)
case "$choice" in
  *"Volume up")   pactl set-sink-volume @DEFAULT_SINK@ +10% ;;
  *"Volume down") pactl set-sink-volume @DEFAULT_SINK@ -10% ;;
  *"Toggle mute"|*"Volume  "*) pactl set-sink-mute @DEFAULT_SINK@ toggle ;;
  *Screenshot) sleep 0.4; mkdir -p ~/Pictures/Screenshots; grim ~/Pictures/Screenshots/hypr-$(date +%Y%m%d-%H%M%S).png && notify-send "Screenshot saved" ;;
  *"Reload Hyprland") hyprctl reload >/dev/null ;;
  *"Log out") hyprctl dispatch 'hl.dsp.exit()' >/dev/null ;;
esac
