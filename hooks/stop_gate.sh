#!/usr/bin/env bash
# Stop gate for the interview kit. Advisory only: always exits 0.
# Runs flutter analyze with an 8s budget and reminds when docs/work/TRACE.md was not touched.
set -euo pipefail
cat >/dev/null 2>&1 || true
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PD="$(printenv CLAUDE_PROJECT_DIR || true)"
if [ -n "$PD" ]; then ROOT="$PD"; fi
cd "$ROOT"
TB="$(printenv TMPDIR || true)"
if [ -z "$TB" ]; then TB=/tmp; fi
MARK="$TB/dsh-kit-session-start"

if command -v flutter >/dev/null 2>&1; then
  OUT="$(mktemp)"
  flutter analyze >"$OUT" 2>&1 &
  PID=$!
  N=0
  while kill -0 "$PID" 2>/dev/null && [ "$N" -lt 16 ]; do sleep 0.5; N=$((N+1)); done
  if kill -0 "$PID" 2>/dev/null; then
    pkill -P "$PID" 2>/dev/null || true
    kill "$PID" 2>/dev/null || true
    echo "flutter analyze: analyze skipped (timeout)"
  else
    wait "$PID" || true
    echo "flutter analyze: $(grep -v '^[[:space:]]*$' "$OUT" | tail -n 1)"
  fi
  rm -f "$OUT"
else
  echo "flutter analyze: flutter not found, skipped"
fi

TRACE="$ROOT/docs/work/TRACE.md"
if [ -f "$MARK" ]; then
  if [ ! -f "$TRACE" ] || [ ! "$TRACE" -nt "$MARK" ]; then
    echo "REMINDER: docs/work/TRACE.md was not updated this session. Record decisions and progress there before you stop."
  fi
else
  echo "TRACE check skipped: no session-start marker."
fi
exit 0
