import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_app/core/url_opener.dart';

void main() {
  test('SilentUrlOpener is a no-op', () {
    const SilentUrlOpener().open('https://example.com/none');
  });

  test('BrowserUrlOpener is safe on non-web platforms', () {
    const BrowserUrlOpener().open('https://example.com/vm');
  });
}
