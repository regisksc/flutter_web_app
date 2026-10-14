import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_app/features/short_links/domain/entities/short_link.dart';

void main() {
  final link = ShortLink(
    code: 'abc1234',
    longUrl: 'https://example.com',
    createdAt: DateTime(2026),
    clickCount: 0,
  );

  test('shortUrl is built from the code on sho.rt', () {
    expect(link.shortUrl, 'https://sho.rt/abc1234');
  });

  test('copyWith changes only the click count', () {
    final opened = link.copyWith(clickCount: 3);
    expect(opened.clickCount, 3);
    expect(opened.code, link.code);
    expect(opened.longUrl, link.longUrl);
  });
}
