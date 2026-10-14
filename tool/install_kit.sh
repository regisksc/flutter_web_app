#!/usr/bin/env bash
# Copies this kit into another repo. Dry run unless --apply. Never overwrites:
# existing files are skipped and their diff is printed so you can compare.
set -euo pipefail
SRC="$(cd "$(dirname "$0")/.." && pwd)"
TARGET=""
APPLY=0
CORE=0
for a in "$@"; do
  case "$a" in
    --apply) APPLY=1 ;;
    --with-core) CORE=1 ;;
    -*) echo "unknown flag: $a"; exit 2 ;;
    *) TARGET=$a ;;
  esac
done
if [ -z "$TARGET" ]; then echo "usage: tool/install_kit.sh <target-repo> [--apply] [--with-core]"; exit 2; fi
if [ ! -d "$TARGET" ]; then echo "target is not a directory: $TARGET"; exit 2; fi
TARGET="$(cd "$TARGET" && pwd)"
if [ "$TARGET" = "$SRC" ]; then echo "target is this kit; nothing to do"; exit 2; fi

ITEMS="AGENTS.md CLAUDE.md CONTEXT.md SHORTCUTS.md NEXT.md docs hooks tool .agents/skills .claude/settings.json"
if [ "$CORE" = 1 ]; then ITEMS="$ITEMS lib/core lib/features/example test/core test/features/example"; fi

if [ "$APPLY" = 1 ]; then echo "MODE: apply -> $TARGET"; else echo "MODE: dry run (add --apply to copy) -> $TARGET"; fi
copied=0
skipped=0
for item in $ITEMS; do
  [ -e "$SRC/$item" ] || continue
  find "$SRC/$item" -type f | sort | while IFS= read -r f; do
    rel="$(printf '%s' "$f" | sed "s|^$SRC/||")"
    dst="$TARGET/$rel"
    if [ -e "$dst" ]; then
      echo "skip  $rel (exists in target)"
      diff -u "$dst" "$f" || true
    else
      if [ "$APPLY" = 1 ]; then
        mkdir -p "$(dirname "$dst")"
        cp -p "$f" "$dst"
        echo "copy  $rel"
      else
        echo "would copy  $rel"
      fi
    fi
  done
done

echo ""
echo "Read target repo's OWN conventions first (its README/AGENTS.md/CLAUDE.md/analysis_options.yaml): THEIR conventions win; adapt kit to them, not reverse."
