#!/usr/bin/env bash
# Scaffold a feature from docs/templates/feature. Usage: tool/new_feature.sh <snake_name>
set -euo pipefail
cd "$(dirname "$0")/.."

if [ $# -ne 1 ]; then echo "usage: tool/new_feature.sh <snake_name>"; exit 2; fi
NAME=$1
if ! printf '%s' "$NAME" | grep -Eq '^[a-z][a-z0-9_]*$'; then
  echo "invalid name '$NAME': use lowercase snake_case starting with a letter"; exit 2
fi
PASCAL="$(printf '%s' "$NAME" | awk -F_ '{for (i=1; i<=NF; i++) printf toupper(substr($i,1,1)) substr($i,2)}')"
TPL=docs/templates/feature
if [ ! -d "$TPL/lib" ] || [ ! -d "$TPL/test" ]; then echo "template missing: $TPL/lib and $TPL/test"; exit 1; fi
if [ -e "lib/features/$NAME" ] || [ -e "test/features/$NAME" ]; then
  echo "refuse: lib/features/$NAME or test/features/$NAME already exists"; exit 1
fi

mkdir -p "lib/features/$NAME" "test/features/$NAME"
cp -R "$TPL/lib/." "lib/features/$NAME/"
cp -R "$TPL/test/." "test/features/$NAME/"

for root in "lib/features/$NAME" "test/features/$NAME"; do
  find "$root" -type f | while IFS= read -r f; do
    printf '%s\n' "$(sed -e "s/__feature__/$NAME/g" -e "s/__Feature__/$PASCAL/g" "$f")" > "$f"
    new="$(printf '%s' "$f" | sed -e "s/__feature__/$NAME/g" -e "s/__Feature__/$PASCAL/g" -e 's/\.tmpl$//')"
    if [ "$new" != "$f" ]; then mkdir -p "$(dirname "$new")"; mv "$f" "$new"; fi
  done
done

echo "Scaffolded feature '$NAME' ($PASCAL):"
echo "  lib/features/$NAME/"
echo "  test/features/$NAME/"
echo "Next steps: read docs/NEW_FEATURE.md, index the new AGENTS.md rows in AGENTS.md,"
echo "write the spec in docs/specs/$NAME.md, then start red tests."
