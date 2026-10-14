#!/usr/bin/env bash
# Line-coverage gate for changed lib/ files, read from coverage/lcov.info.
# Usage: tool/coverage_check.sh [min-percent]   (default THRESHOLD below)
set -euo pipefail
THRESHOLD=80
if [ $# -ge 1 ]; then THRESHOLD=$1; fi
cd "$(dirname "$0")/.."

LCOV=coverage/lcov.info
if [ ! -f "$LCOV" ]; then
  echo "coverage/lcov.info missing: run flutter test --coverage first"
  exit 1
fi

CHANGED="$( { git diff --name-only HEAD 2>/dev/null || true; git ls-files -o --exclude-standard -- lib 2>/dev/null || true; } \
  | grep -E '^lib/.*\.dart$' | grep -v '^lib/main\.dart$' | sort -u || true)"

if [ -z "$CHANGED" ]; then
  echo "coverage OK (no changed lib files)"
  exit 0
fi

fail=0
printf '%-50s %8s %8s %8s\n' "file" "lines" "hit" "pct"
while IFS= read -r f; do
  [ -n "$f" ] || continue
  stats="$(awk -v F="$f" 'BEGIN{lf=0; lh=0; found=0; cur=""}
    /^SF:/ {cur=substr($0,4)}
    cur==F && /^LF:/ {lf=substr($0,4); found=1}
    cur==F && /^LH:/ {lh=substr($0,4)}
    /^end_of_record/ {cur=""}
    END {print found, lf+0, lh+0}' "$LCOV")"
  read -r found lf lh <<< "$stats"
  if [ "$found" = "0" ]; then
    if grep -Eq ') *(async *)?(\{|=>)' "$f"; then
      printf '%-50s %8s %8s %8s\n' "$f" "-" "-" "0.0 (missing)"
      fail=1
    else
      printf '%-50s %8s %8s %8s\n' "$f" "-" "-" "no code"
    fi
    continue
  fi
  if [ "$lf" -eq 0 ]; then
    printf '%-50s %8s %8s %8s\n' "$f" "0" "0" "skip"
    continue
  fi
  pct="$(awk -v a="$lh" -v b="$lf" 'BEGIN{printf "%.1f", a*100/b}')"
  printf '%-50s %8s %8s %8s\n' "$f" "$lf" "$lh" "$pct"
  if awk -v p="$pct" -v t="$THRESHOLD" 'BEGIN{exit !(p < t)}'; then fail=1; fi
done <<< "$CHANGED"

if [ "$fail" -ne 0 ]; then
  echo "coverage FAILED: a changed lib file is below $THRESHOLD%"
  exit 1
fi
echo "coverage OK (threshold $THRESHOLD%)"
