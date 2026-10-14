# The web build uses a real redirect server; other platforms stay offline

A shortener only counts if the short URL really forwards, so the web build talks to tool/redirect_server.py (stdlib Python, no dependencies) through HttpShortLinkBackend, which implements the same ShortLinkRemoteDataSource as the in-memory fake. The server stores links in .redirect_state.json, answers GET /<code> with a 302 and counts the click, and builds every short URL per request from the public host (or the pinned .public_base_url), so no link ever contains localhost. It also serves build/web, so one process and one Tailscale Funnel port is the whole deployment. iOS and tests keep the in-memory fake (ADR 0001).

Status: accepted. Supersedes the web part of ADR 0001.

## Update: short domain via TinyURL

The Tailscale host name is long, so on creation the server also asks TinyURL (free public API, no key, stdlib urllib) to shorten https://<host>/<code>. The link people see and copy is then https://tinyurl.com/xxxxxxxx (28 chars). Following it goes tinyurl.com, then our server (which counts the click and answers 302), then the destination. If TinyURL is unreachable the link keeps our own URL, so shortening never breaks. is.gd was tried first and rejected our host.
