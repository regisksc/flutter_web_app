import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_app/features/short_links/data/models/short_link_model.dart';
import 'package:flutter_web_app/features/short_links/data/models/short_link_page_model.dart';

void main() {
  group('server-shaped JSON (tool/redirect_server.py)', () {
    final json = {
      'code': 'abc1234',
      'long_url': 'https://example.com/x',
      'created_at': 1792008182.5,
      'clicks': 3,
      'short_url': 'https://host.example/go/abc1234',
    };

    test('maps epoch seconds, clicks and the server short url', () {
      final link = ShortLinkModel.fromJson(json).toEntity();

      expect(link.clickCount, 3);
      expect(link.createdAt.millisecondsSinceEpoch, 1792008182500);
      expect(link.shortUrl, 'https://host.example/go/abc1234');
    });

    test('falls back to the placeholder short url without one', () {
      final withoutUrl = Map<String, dynamic>.of(json)..remove('short_url');

      expect(
        ShortLinkModel.fromJson(withoutUrl).toEntity().shortUrl,
        'https://sho.rt/abc1234',
      );
    });

    test('copyWith keeps the server short url', () {
      final link = ShortLinkModel.fromJson(
        json,
      ).toEntity().copyWith(clickCount: 4);

      expect(link.shortUrl, 'https://host.example/go/abc1234');
      expect(link.clickCount, 4);
    });

    test('page accepts an int next_cursor', () {
      final page = ShortLinkPageModel.fromJson({
        'items': [json],
        'next_cursor': 10,
      });

      expect(page.nextCursor, '10');
    });
  });
}
