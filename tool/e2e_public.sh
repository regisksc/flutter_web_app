#!/usr/bin/env bash
# End-to-end smoke test against the PUBLIC URL, resolving DNS the way an outside visitor would.
# Usage: tool/e2e_public.sh [https://public-host]   (default: contents of .public_base_url)
set -euo pipefail
cd "$(dirname "$0")/.."
BASE=${1:-$(cat .public_base_url)}
H=${BASE#https://}
IP=$(dig +short @1.1.1.1 "$H" | head -1)
[ -n "$IP" ] || { echo "FAIL: $H does not resolve on public DNS"; exit 1; }
C="curl -s -m 25 --resolve $H:443:$IP"
echo "public DNS $H -> $IP"
code=$($C -o /dev/null -w '%{http_code}' "$BASE/"); [ "$code" = 200 ] || { echo "FAIL: app page $code"; exit 1; }
$C "$BASE/main.dart.js" -o /tmp/e2e_bundle.js
grep -q 'api/shorten' /tmp/e2e_bundle.js || { echo 'FAIL: served bundle is stale (no /api/shorten)'; exit 1; }
R=$($C -X POST "$BASE/api/shorten" -d '{"long_url":"https://www.iana.org/about"}')
S=$(echo "$R" | python3 -c 'import json,sys; print(json.load(sys.stdin)["short_url"])')
case "$S" in https://127.*|http://127.*|*localhost*) echo "FAIL: localhost short url $S"; exit 1;; esac
HOPS=1
case "$S" in
  https://tinyurl.com/*) HOPS=2 ;;   # short domain -> our server -> destination
  "$BASE"/*) ;;                       # fallback: our own host
  *) echo "FAIL: unexpected short url: $S"; exit 1 ;;
esac
OUT=$($C -L -o /dev/null -w '%{url_effective} %{http_code} %{num_redirects}' "$S")
[ "$OUT" = "https://www.iana.org/about 200 $HOPS" ] || { echo "FAIL: forwarding gave: $OUT (want $HOPS redirects)"; exit 1; }
echo "OK shortened -> $S (${#S} chars)"
echo "OK forwarded -> https://www.iana.org/about ($HOPS redirects, 200)"