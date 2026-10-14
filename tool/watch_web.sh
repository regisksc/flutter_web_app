#!/usr/bin/env bash
# Rebuild build/web whenever lib/, web/ or pubspec.yaml change, so the public URL always serves the latest code.
# Run in the background: tool/watch_web.sh &   (redirect_server.py reads build/web per request; no restart needed)
set -uo pipefail
cd "$(dirname "$0")/.."
export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
stamp=/tmp/flutter_web_app.build.stamp
touch -t 197001010000 "$stamp"
while true; do
  if [ -n "$(find lib web pubspec.yaml -newer "$stamp" -type f 2>/dev/null | head -1)" ]; then
    touch "$stamp"
    echo "[watch_web] $(date +%T) change detected, rebuilding"
    # Build aside, then swap: visitors never see a half-written build/web.
    if flutter build web --release --pwa-strategy=none --output build/web_next 2>&1 | tail -1 | grep -q Built; then
      rsync -a --delete build/web_next/ build/web/ && echo "[watch_web] $(date +%T) published"
    else
      echo "[watch_web] build failed; previous build keeps serving"
    fi
  fi
  sleep 4
done