#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
B=${REDIRECT_TEST_BASE:-http://127.0.0.1:8877}
OWN_PID=
if ! curl -s -m 2 "$B/" > /dev/null; then
  python3 tool/redirect_server.py >/tmp/redirect_test.log 2>&1 &
  OWN_PID=$!
  sleep 1
fi
trap '[ -n "$OWN_PID" ] && kill $OWN_PID 2>/dev/null || true' EXIT
r1=$(curl -s -X POST "$B/api/shorten" -d '{"long_url":"https://example.com/one"}')
echo "create: $r1"
code=$(echo "$r1" | python3 -c 'import json,sys; print(json.load(sys.stdin)["code"])')
curl -s -X POST "$B/api/shorten" -d '{"long_url":"https://example.com/two","alias":"promo"}' > /dev/null
dup=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$B/api/shorten" -d '{"long_url":"https://example.com/two","alias":"promo"}')
echo "duplicate alias status: $dup (want 409)"
badu=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$B/api/shorten" -d '{"long_url":"ftp://x"}')
echo "bad url status: $badu (want 400)"
S=$(echo "$r1" | python3 -c 'import json,sys; print(json.load(sys.stdin)["short_url"])')
rc=$(curl -s -o /dev/null -w '%{http_code}' "$S")
loc=$(curl -s -D - -o /dev/null "$S" | grep -i '^Location' | tr -d '\r')
echo "redirect status: $rc (want 302) $loc"
clicks=$(curl -s "$B/api/links/$code" | python3 -c 'import json,sys; print(json.load(sys.stdin)["clicks"])')
echo "clicks after one redirect: $clicks (want 1)"
curl -s "$B/api/links?limit=2" | python3 -c 'import json,sys; d=json.load(sys.stdin); print("list newest first:", [i["code"] for i in d["items"]], "next:", d["next_cursor"])'
curl -s "$B/" | head -c 40; echo
echo 'redirect server tests done'