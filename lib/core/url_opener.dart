import 'url_opener_stub.dart'
    if (dart.library.html) 'url_opener_web.dart'
    as backend;

/// Opens the destination of a short link in a browser tab.
abstract interface class UrlOpener {
  /// Opens [url]; never throws into the caller.
  void open(String url);
}

/// Does nothing; used by tests and by callers that must not open anything.
class SilentUrlOpener implements UrlOpener {
  const SilentUrlOpener();

  @override
  void open(String url) {}
}

/// Opens in a browser tab on web; on other platforms the stub makes it a no-op.
// ponytail: web-only opening. iOS needs url_launcher (native bridge, banned) or a real redirect server; add one when a backend exists.
class BrowserUrlOpener implements UrlOpener {
  const BrowserUrlOpener();

  @override
  void open(String url) {
    if (backend.isWebOpenSupported) backend.webOpen(url);
  }
}
