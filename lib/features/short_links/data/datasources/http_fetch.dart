// coverage:platform-only (VM tests cannot run this platform arm)
// One generic fetch helper on top of dart:js_interop. No http package needed.
import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// Runs a fetch against [path] (same origin) and returns the parsed JSON body.
Future<Map<String, dynamic>> fetchJson(
  String method,
  String path,
  String? body, {
  required void Function(int status, String? message) onError,
}) async {
  final opts = JSObject();
  opts.setProperty('method'.toJS, method.toJS);
  final headers = JSObject();
  headers.setProperty('Content-Type'.toJS, 'application/json'.toJS);
  opts.setProperty('headers'.toJS, headers);
  if (body != null) {
    opts.setProperty('body'.toJS, body.toJS);
  }
  final fetchFn = globalContext.getProperty<JSFunction>('fetch'.toJS);
  final promise =
      fetchFn.callAsFunction(globalContext, path.toJS, opts)
          as JSPromise<JSAny?>;
  final jsAny = await promise.toDart;
  final resp = jsAny as JSObject;
  final status = (resp.getProperty<JSNumber>('status'.toJS)).toDartInt;
  final textP = resp.callMethod<JSAny?>('text'.toJS) as JSPromise<JSString>;
  final text = (await textP.toDart).toDart;
  if (status >= 400) {
    String? message = text;
    try {
      message = (jsonDecode(text) as Map<String, dynamic>)['error'] as String?;
    } catch (_) {
      // keep raw text
    }
    onError(status, message);
  }
  return jsonDecode(text) as Map<String, dynamic>;
}
