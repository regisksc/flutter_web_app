import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_app/features/short_links/data/models/short_link_model.dart';
import 'package:flutter_web_app/features/short_links/data/models/short_link_page_model.dart';
import 'package:flutter_web_app/features/short_links/domain/entities/short_link.dart';

void main() {
  final json = {
    'code': 'abc1234',
    'long_url': 'https://example.com',
    'created_at': '2026-01-01T00:00:00.000Z',
    'click_count': 2,
  };
  final entity = ShortLink(
    code: 'abc1234',
    longUrl: 'https://example.com',
    createdAt: DateTime.utc(2026),
    clickCount: 2,
  );

  test('ShortLinkModel reads snake_case JSON', () {
    final model = ShortLinkModel.fromJson(json);

    expect(model.toEntity(), entity);
  });

  test('ShortLinkModel writes snake_case JSON that reads back the same', () {
    expect(ShortLinkModel.fromEntity(entity).toJson(), json);
    expect(ShortLinkModel.fromJson(json).toJson(), json);
  });

  test('ShortLinkPageModel maps items and a null cursor', () {
    final page = ShortLinkPageModel.fromJson({
      'items': [json],
      'next_cursor': null,
    });

    expect(page.toEntity().items, [entity]);
    expect(page.toEntity().nextCursor, isNull);
  });

  test('ShortLinkPageModel keeps the next cursor', () {
    final page = ShortLinkPageModel.fromJson({
      'items': <Map<String, dynamic>>[],
      'next_cursor': '10',
    });

    expect(page.toEntity().nextCursor, '10');
    expect(page.toJson()['next_cursor'], '10');
  });
}
