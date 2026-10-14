#!/usr/bin/env bash
# SessionStart hook: prints the AGENTS.md INDEX table and startup reminders.
set -euo pipefail
cat >/dev/null 2>&1 || true
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PD="$(printenv CLAUDE_PROJECT_DIR || true)"
if [ -n "$PD" ]; then ROOT="$PD"; fi
TB="$(printenv TMPDIR || true)"
if [ -z "$TB" ]; then TB=/tmp; fi
touch "$TB/dsh-kit-session-start"

AG="$ROOT/AGENTS.md"
if [ -f "$AG" ]; then
  echo "## AGENTS.md INDEX"
  awk '/^#.*INDEX/ {f=1; next} f && /^#/ {f=0} f && /^\|/ {print}' "$AG"
fi
echo "Startup: run /opt/homebrew/bin/graphify, then recall AgentMemory (mcp__agentmemory__memory_recall) for this project before coding."
exit 0
