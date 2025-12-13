#!/bin/bash
# CPU usage
CPU=$(top -l 1 | grep -E "^CPU" | awk '{print $3}' | tr -d '%')
sketchybar --set $NAME label="${CPU}%"

