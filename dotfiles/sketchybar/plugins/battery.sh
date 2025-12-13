#!/bin/bash
# Battery status
BATTERY=$(pmset -g batt | grep -Eo "\d+%" | head -1)
CHARGING=$(pmset -g batt | grep -c "AC Power")

if [ "$CHARGING" -gt 0 ]; then
  ICON="󰂄"
else
  # Different icons based on level
  LEVEL=${BATTERY%\%}
  if [ "$LEVEL" -gt 80 ]; then
    ICON="󰁹"
  elif [ "$LEVEL" -gt 60 ]; then
    ICON="󰂀"
  elif [ "$LEVEL" -gt 40 ]; then
    ICON="󰁾"
  elif [ "$LEVEL" -gt 20 ]; then
    ICON="󰁼"
  else
    ICON="󰁺"
  fi
fi

sketchybar --set $NAME icon="$ICON" label="$BATTERY"

