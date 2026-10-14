#!/usr/bin/env bash
# Keeps the shortener serving for N days (default 7): redirect server, web watcher, public funnel.
# Run by launchd (tool/com.regis.flutter-keepalive.plist); safe to run by hand: tool/keep_serving.sh [days]
set -uo pipefail
cd "$(dirname "$0")/.."
DAYS=${1:-7}
UNTIL_FILE=.keep_serving_until   # written once so a restart never extends the week
now=$(date +%s)
if [ -f "$UNTIL_FILE" ]; then until=$(cat "$UNTIL_FILE"); else until=$((now + DAYS * 86400)); echo "$until" > "$UNTIL_FILE"; fi
UIDN=$(id -u)
BASE=$(cat .public_base_url 2>/dev/null || true)
TS=$(command -v tailscale || echo /Applications/Tailscale.app/Contents/MacOS/Tailscale)
export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
log() { echo "[keep_serving] $(date '+%F %T') $*"; }
api_ok() { curl -sf -m 5 'http://127.0.0.1:8877/api/links?limit=1' > /dev/null; }

ensure_server() {
  api_ok && return 0
  log 'api down: restarting redirect server'
  launchctl bootout "gui/$UIDN/com.regis.flutter-web-app" 2>/dev/null   # the old static server would hold :8877
  if launchctl print "gui/$UIDN/com.regis.flutter-redirect" > /dev/null 2>&1; then
    launchctl kickstart -k "gui/$UIDN/com.regis.flutter-redirect"
  else
    launchctl bootstrap "gui/$UIDN" "$PWD/tool/com.regis.flutter-redirect.plist"
  fi
  sleep 3
  if ! api_ok; then
    log 'launchd start failed: starting directly'
    nohup python3 tool/redirect_server.py >> /tmp/flutter-redirect.log 2>&1 &
    sleep 2
  fi
}

ensure_watcher() {
  pgrep -f 'tool/watch_web.sh' > /dev/null && return 0
  log 'starting web watcher'
  nohup tool/watch_web.sh >> /tmp/watch_web.log 2>&1 &
}

ensure_public() {
  [ -n "$BASE" ] || return 0
  api_ok || return 0   # server first; funnel cannot help if it is down
  curl -sf -m 15 "$BASE/api/links?limit=1" > /dev/null && return 0
  log "public URL $BASE down: re-enabling funnel"
  "$TS" funnel --bg 8877 > /dev/null 2>&1 || log 'funnel command failed'
}

log "start; serving until $(date -r "$until" '+%F %T')"
caffeinate -i -w $$ &   # no idle sleep while this runs
while [ "$(date +%s)" -lt "$until" ]; do
  ensure_server
  ensure_watcher
  ensure_public
  sleep 30
done
log 'week is over: stopping (rm .keep_serving_until and rerun for another week)'