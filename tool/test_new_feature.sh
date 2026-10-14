#!/usr/bin/env bash
# Temp-tree test for tool/new_feature.sh: scaffolds into a copy, never touches the repo.
set -euo pipefail
SRC="$(cd "$(dirname "$0")/.." && pwd)"
T="$(mktemp -d)"
trap 'rm -rf "$T"' EXIT
mkdir -p "$T/tool" "$T/docs/templates/feature/lib/domain" "$T/docs/templates/feature/test/domain" "$T/lib" "$T/test"
cp "$SRC/tool/new_feature.sh" "$T/tool/"
printf 'class __Feature__Entity {}\n' > "$T/docs/templates/feature/lib/domain/__feature___entity.dart.tmpl"
printf 'import __feature__;\n' > "$T/docs/templates/feature/test/domain/__feature___test.dart.tmpl"
cd "$T"
bash tool/new_feature.sh my_orders >/dev/null
test -f lib/features/my_orders/domain/my_orders_entity.dart
test -f test/features/my_orders/domain/my_orders_test.dart
grep -q 'class MyOrdersEntity' lib/features/my_orders/domain/my_orders_entity.dart
grep -q 'import my_orders;' test/features/my_orders/domain/my_orders_test.dart
if bash tool/new_feature.sh my_orders >/dev/null 2>&1; then echo "FAIL: duplicate not refused"; exit 1; fi
if bash tool/new_feature.sh Bad-Name >/dev/null 2>&1; then echo "FAIL: bad name accepted"; exit 1; fi
echo "new_feature OK"
