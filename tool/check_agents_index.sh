#!/usr/bin/env bash
# Checks that every AGENTS.md in the repo is listed in the root INDEX table, that each
# indexed file exists, and that line caps hold (root 150, others 60).
set -euo pipefail
cd "$(dirname "$0")/.."

ROWS="$(awk '/^#.*INDEX/ {f=1; next} f && /^#/ {f=0} f && /^\|/ {print}' AGENTS.md \
  | awk -F'|' 'NR>2 { d=$2; f=$3; gsub(/ /, "", d); gsub(/ /, "", f); if (d != "") print d " " f }')"

INDEXED=""
while IFS= read -r row; do
  [ -n "$row" ] || continue
  dir="$(printf '%s' "$row" | cut -d' ' -f1)"
  file="$(printf '%s' "$row" | cut -d' ' -f2-)"
  if [ "$dir" = "./" ]; then p="$file"; else p="$dir$file"; fi
  INDEXED="$INDEXED$p
"
done <<< "$ROWS"

EXCL="-path ./docs/templates -o -path ./.agents -o -path ./.dart_tool -o -path ./build -o -path ./ios -o -path ./node_modules -o -path ./graphify-out -o -path ./coverage"
FOUND="$(find . \( $EXCL \) -prune -o -name AGENTS.md -print | sed 's|^\./||' | sort)"

problems=""
count=0
while IFS= read -r p; do
  [ -n "$p" ] || continue
  if ! grep -qxF "$p" <<< "$INDEXED"; then problems="$problems
not indexed: $p"; fi
done <<< "$FOUND"

while IFS= read -r p; do
  [ -n "$p" ] || continue
  count=$((count + 1))
  if [ ! -f "$p" ]; then problems="$problems
indexed file missing: $p"; continue; fi
  cap=60
  if [ "$p" = "AGENTS.md" ]; then cap=150; fi
  lines="$(wc -l < "$p" | tr -d ' ')"
  if [ "$lines" -gt "$cap" ]; then problems="$problems
over cap ($lines > $cap): $p"; fi
done <<< "$INDEXED"

if [ -n "$problems" ]; then
  echo "AGENTS index check FAILED:$problems"
  exit 1
fi
echo "OK: $count AGENTS.md indexed"
