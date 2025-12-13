#!/bin/bash
# WiFi status
SSID=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | grep ' SSID' | awk '{print $2}')
if [ -z "$SSID" ]; then
  sketchybar --set $NAME icon=󰖪 label="Off"
else
  sketchybar --set $NAME icon=󰖩 label="$SSID"
fi

