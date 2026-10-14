import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_app/app/app.dart';
import 'package:flutter_web_app/app/bootstrap.dart';
import 'package:flutter_web_app/core/testing/keys.dart';
import 'package:flutter_web_app/features/example/data/datasources/article_remote_data_source.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('user loads the first page and then the next page', (
    tester,
  ) async {
    await tester.pumpWidget(
      App(
        dependencies: AppDependencies.create(
          dataSource: const FakeArticleRemoteDataSource(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(AppKeys.articleTile('0')), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(AppKeys.loadMoreButton),
      300,
      scrollable: find.descendant(
        of: find.byKey(AppKeys.articleList),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.tap(find.byKey(AppKeys.loadMoreButton));
    await tester.pumpAndSettle();

    expect(find.byKey(AppKeys.articleTile('10')), findsOneWidget);
  });
}
