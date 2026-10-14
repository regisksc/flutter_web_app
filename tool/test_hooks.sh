#!/usr/bin/env bash
# Feeds sample payloads to the hooks and asserts allow/deny. Exit 1 on any failure.
set -euo pipefail
cd "$(dirname "$0")/.."
ROOT="$(pwd)"
H="$ROOT/hooks"
TMPP="$(mktemp -d)"
trap 'rm -rf "$TMPP"' EXIT
fails=0

pre() { # pre <tool> <tool_input-json> <expected-exit> <label>
  local payload code=0
  payload="$(python3 -c 'import json,sys; print(json.dumps({"hook_event_name":"PreToolUse","tool_name":sys.argv[1],"tool_input":json.loads(sys.argv[2]),"cwd":"."}))' "$1" "$2")"
  printf '%s' "$payload" | CLAUDE_PROJECT_DIR="$TMPP" "$H/pre_tool_guard.sh" >/dev/null 2>&1 || code=$?
  if [ "$code" = "$3" ]; then echo "ok   - $4 (exit $code)"; else echo "FAIL - $4 (want $3, got $code)"; fails=$((fails + 1)); fi
}

pre Bash '{"command":"git commit -m wip"}' 2 "git commit is denied"
pre Bash '{"command":"git push origin main"}' 2 "git push is denied"
pre Bash '{"command":"git checkout -b feat/x"}' 2 "branch creation is denied"
pre Bash '{"command":"git add lib/main.dart"}' 2 "git add is denied"
pre Bash '{"command":"git status"}' 0 "git status is allowed"
pre Edit '{"file_path":"'"$ROOT"'/pubspec.yaml","old_string":"a","new_string":"dependencies:"}' 2 "pubspec edit denied without .allow-deps"
touch "$TMPP/.allow-deps"
pre Edit '{"file_path":"'"$ROOT"'/pubspec.yaml","old_string":"a","new_string":"dependencies:"}' 0 "pubspec edit allowed with .allow-deps"
rm -f "$TMPP/.allow-deps"
pre Edit '{"file_path":"'"$ROOT"'/lib/main.dart","old_string":"a","new_string":"b"}' 0 "lib edit is allowed"

stop_out="$(printf '{}' | CLAUDE_PROJECT_DIR="$ROOT" "$H/stop_gate.sh" 2>&1)" && stop_code=0 || stop_code=$?
if [ "$stop_code" = "0" ] && printf '%s' "$stop_out" | grep -q "flutter analyze:"; then
  echo "ok   - stop gate exits 0 and reports analyze"
else
  echo "FAIL - stop gate (exit $stop_code)"; fails=$((fails + 1))
fi

ss_out="$(printf '{}' | CLAUDE_PROJECT_DIR="$ROOT" "$H/session_start.sh" 2>&1)" && ss_code=0 || ss_code=$?
if [ "$ss_code" = "0" ] && printf '%s' "$ss_out" | grep -q "Startup:"; then
  echo "ok   - session start prints reminder"
else
  echo "FAIL - session start (exit $ss_code)"; fails=$((fails + 1))
fi

if [ "$fails" -eq 0 ]; then echo "hooks OK"; exit 0; fi
echo "hooks FAILED: $fails"
exit 1
