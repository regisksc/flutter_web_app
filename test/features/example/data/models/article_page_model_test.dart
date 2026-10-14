import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_app/features/example/data/models/article_model.dart';
import 'package:flutter_web_app/features/example/data/models/article_page_model.dart';
import 'package:flutter_web_app/features/example/domain/entities/article.dart';
import 'package:flutter_web_app/features/example/domain/entities/article_page.dart';

void main() {
  test('maps JSON with a cursor to a domain page', () {
    final model = ArticlePageModel.fromJson({
      'items': [
        {'id': '1', 'title': 'T', 'summary': 'S'},
      ],
      'next_cursor': '10',
    });

    expect(
      model.toEntity(),
      const ArticlePage(
        items: [Article(id: '1', title: 'T', summary: 'S')],
        nextCursor: '10',
      ),
    );
  });

  test('keeps a null cursor on the last page', () {
    final model = ArticlePageModel.fromJson({
      'items': <Map<String, dynamic>>[],
      'next_cursor': null,
    });

    expect(model.toEntity(), const ArticlePage(items: []));
  });

  test('article model round-trips through JSON', () {
    final json = {'id': '1', 'title': 'T', 'summary': 'S'};

    expect(ArticleModel.fromJson(json).toJson(), json);
  });

  test('missing title throws TypeError', () {
    expect(
      () => ArticlePageModel.fromJson({
        'items': [
          {'id': '1', 'summary': 'S'},
        ],
        'next_cursor': null,
      }),
      throwsA(isA<TypeError>()),
    );
  });
}
