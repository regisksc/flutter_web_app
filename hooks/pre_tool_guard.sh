#!/usr/bin/env bash
# PreToolUse guard for the interview kit. Blocks commits, pushes, branch changes,
# and dependency/threshold edits. Exit 2 blocks; stderr carries the reason.
# Dependency edits are allowed only when a .allow-deps file exists in the project root.
set -euo pipefail

INPUT="$(cat)"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PD="$(printenv CLAUDE_PROJECT_DIR || true)"
if [ -n "$PD" ]; then ROOT="$PD"; fi

json_get() {
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$INPUT" | jq -r --arg p "$1" 'getpath($p | split(".")) // empty | if type == "string" then . else tojson end' 2>/dev/null || true
  else
    printf '%s' "$INPUT" | python3 -c 'import json,sys
d = json.load(sys.stdin)
for k in sys.argv[1].split("."):
    d = d.get(k) if isinstance(d, dict) else None
if d is None:
    print("")
elif isinstance(d, str):
    print(d)
else:
    print(json.dumps(d))' "$1" 2>/dev/null || true
  fi
}

deny() { echo "pre_tool_guard BLOCKED: $1" >&2; exit 2; }
guard_deps() { [ -f "$ROOT/.allow-deps" ] || deny "$1 (create .allow-deps in the project root to allow)"; }

TOOL="$(json_get tool_name)"
case "$TOOL" in
  Bash|bash)
    CMD="$(json_get tool_input.command)"
    if printf '%s' "$CMD" | grep -Eq 'git( +-C +[^ ]+)? +(commit|push|init|add|stage)([[:space:]]|$)'; then
      deny "git commit/push/init/add/stage is a human step in this kit"
    fi
    if printf '%s' "$CMD" | grep -Eq 'git[^;&|]* (checkout +-[bB]|switch +-[cC]|branch +-[dDmM])([[:space:]]|$)'; then
      deny "branch changes are blocked"
    fi
    if printf '%s' "$CMD" | grep -Eq 'sed +-i.*(pubspec\.yaml|coverage_check\.sh)'; then
      guard_deps "sed -i on pubspec.yaml or coverage threshold"
    fi
    if printf '%s' "$CMD" | grep -Eq 'pub +(add|upgrade|remove)'; then
      guard_deps "dependency change via pub"
    fi
    ;;
  Edit|edit|Write|write|MultiEdit)
    FP="$(json_get tool_input.file_path)"
    if [ -z "$FP" ]; then FP="$(json_get tool_input.path)"; fi
    PAY="$(json_get tool_input)"
    case "$FP" in
      *pubspec.yaml) guard_deps "edit to pubspec.yaml" ;;
      *coverage_check.sh)
        if printf '%s' "$PAY" | grep -q THRESHOLD; then guard_deps "coverage threshold edit"; fi
        ;;
    esac
    ;;
esac
exit 0
