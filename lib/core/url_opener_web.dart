// coverage:platform-only (VM tests cannot run this platform arm)
// Web-only platform code, selected on web builds (dart.library.html).
// Uses dart:js_interop only (SDK libraries), so no extra package is needed.
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// Whether opening in a browser is supported on this platform.
const bool isWebOpenSupported = true;

/// Opens [url] in a new browser tab (window.open).
void webOpen(String url) {
  globalContext
      .getProperty<JSObject>('window'.toJS)
      .callMethod('open'.toJS, url.toJS, '_blank'.toJS);
}
