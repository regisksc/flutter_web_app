// coverage:platform-only (VM tests cannot run this platform arm)
// Non-web platform stub; selected on VM/IO builds (dart.library.html is false there).

/// Whether opening in a browser is supported on this platform.
const bool isWebOpenSupported = false;

/// No-op on non-web platforms.
void webOpen(String url) {}
