# Trace

Append-only narration log. Newest at the bottom.

## 2026-10-14 - kit creation (seed)

- INTENT: create the documentation layer of the Outsmart interview kit.
- LOOKING: flutter_web_app has stock README and a single lib/main.dart; no docs/ or tests yet.
- DECISION: index rows for each AGENTS.md; keep templates out of the index. Replace stock README.
- EVIDENCE: README was 17 lines stock Flutter text; repo layout checked with ls.
- RISK: infra scripts (tool/check_agents_index.sh) not yet verified against the index format.

## 2026-10-14 - short_links (Bitly) feature

- INTENT: product is a Bitly-style shortener; build frontend and backend logic with the kit's own flow.
- LOOKING: example feature shape; no HTTP package allowed.
- DECISION: in-process backend behind the data-source interface (rejected: dart:io HttpServer, needs a server process and breaks web). Builder detects create by list-head change, because the zero-latency bloc skips the creating state per frame.
- EVIDENCE: flutter analyze clean; flutter test --coverage 140 passed; integration tests passed on iPhone 17 simulator.
- RISK: sonnet child's view test needed one extra pump(); backend is in-memory only.

## 2026-10-14 - public URL showed the old scaffold

- INTENT: make https://macbook-pro.tail03a77e.ts.net show the shortener, not the stock app.
- LOOKING: tailscale funnel -> 127.0.0.1:8877 -> python http.server on build/web (launchd com.regis.flutter-web-app); build/web held the stock build.
- DECISION: rebuild with flutter build web --release --pwa-strategy=none (no service worker, so browsers cannot keep serving the old app). Rejected: restarting the server; it reads files per request.
- EVIDENCE: public main.dart.js contains Shortener; Playwright on the public URL: type URL, Shorten, result card + list tile appear, field cleared (screenshot docs/work/web_after_shorten.png).
- RISK: re-run the web build after every lib change, or the URL goes stale again.

## 2026-10-14 - Marionette verified

- INTENT: close the last unverified stub (Marionette).
- LOOKING: marionette_mcp binary existed in ~/.pub-cache/bin; marionette_flutter package resolve-able.
- DECISION: added marionette_flutter with kDebugMode guard in main.dart (brief authorizes install if verifiable by debug run); drove the app over mcporter keep-alive daemon, not one-shot calls.
- EVIDENCE: enter_text urlField + tap shorten -> shortLinks.latestResult with https://sho.rt/x90HETg and tile x90HETg, field cleared; flutter analyze No issues found.
- RISK: extra dependency to remove if interviewer repo forbids it (NEXT.md row).
