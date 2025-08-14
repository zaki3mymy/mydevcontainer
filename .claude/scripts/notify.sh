#!/bin/bash
# NTFY_TOPIC が設定されていなければ何もしない
if [ -z "$NTFY_TOPIC" ]; then
  exit 0
fi

curl -d "Notification from Claude Code" ntfy.sh/$NTFY_TOPIC
