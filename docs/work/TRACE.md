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

## 2026-10-14 - Open goes to the long URL

- INTENT: user reported the short link does not open the original; sho.rt has no DNS so browsers can never resolve it.
- LOOKING: Safari error cannot find server sho.rt; Open only counted a click.
- DECISION: Open affordances open the long URL via a UrlOpener seam (dart:js_interop on web through a conditional import; stub on iOS). Rejected url_launcher (native bridge, out of scope) and opening sho.rt directly (unresolvable).
- EVIDENCE: window.open captured with the long URL on the public site; tile shows 1 click after open; 2 new widget tests cover open and short-url-text tap; analyze clean.
- RISK: on iOS Open counts only until a real redirect server or url_launcher is approved (SHORTCUTS.md row).

## 2026-10-14 - real shortening and forwarding

- INTENT: short URLs must resolve for people outside this network; the in-memory fake produced sho.rt links that no DNS can resolve.
- LOOKING: Tailscale Funnel proxies the public host to 127.0.0.1:8877, previously a static python http.server.
- DECISION: stdlib Python redirect server (API + 302 + static) behind the same data-source interface; HttpShortLinkBackend uses dart:js_interop fetch on web (no package). Short URL built per request from the public host or .public_base_url, never stored. Dropped /go/ to shorten links. Rejected: a custom domain (needs DNS purchase) and an http package (dependency).
- EVIDENCE: tool/e2e_public.sh resolves the host on 1.1.1.1, shortens, and follows the 302 to the destination (200, 1 redirect); Playwright shortened plain, alias and invalid URLs in the browser.
- RISK: the hostname is long (Tailscale name); one process, JSON file store, no auth.
