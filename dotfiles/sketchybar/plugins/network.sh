#!/bin/bash
# Network bandwidth
INTERFACE=$(route get default 2>/dev/null | grep interface | awk '{print $2}')
if [ -z "$INTERFACE" ]; then
  sketchybar --set $NAME label="--"
  exit 0
fi

# Get current bytes
BYTES_IN=$(netstat -ibn | grep -e "$INTERFACE" -m 1 | awk '{print $7}')
BYTES_OUT=$(netstat -ibn | grep -e "$INTERFACE" -m 1 | awk '{print $10}')

# Store for next run
PREV_IN=$(cat /tmp/sketchybar_net_in 2>/dev/null || echo 0)
PREV_OUT=$(cat /tmp/sketchybar_net_out 2>/dev/null || echo 0)
echo $BYTES_IN > /tmp/sketchybar_net_in
echo $BYTES_OUT > /tmp/sketchybar_net_out

# Calculate speed (bytes per 2 seconds)
IN_DIFF=$((($BYTES_IN - $PREV_IN) / 2))
OUT_DIFF=$((($BYTES_OUT - $PREV_OUT) / 2))

# Format to human readable
format_bytes() {
  local bytes=$1
  if [ $bytes -gt 1048576 ]; then
    echo "$(($bytes / 1048576))M"
  elif [ $bytes -gt 1024 ]; then
    echo "$(($bytes / 1024))K"
  else
    echo "${bytes}B"
  fi
}

DOWN=$(format_bytes $IN_DIFF)
UP=$(format_bytes $OUT_DIFF)

sketchybar --set $NAME label="↓${DOWN} ↑${UP}"

