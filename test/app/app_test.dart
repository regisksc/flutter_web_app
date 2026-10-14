import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_app/app/app.dart';
import 'package:flutter_web_app/app/bootstrap.dart';
import 'package:flutter_web_app/core/flags/feature_flags.dart';
import 'package:flutter_web_app/core/testing/keys.dart';
import 'package:flutter_web_app/features/example/data/datasources/article_remote_data_source.dart';

void main() {
  testWidgets('shows the article list when the flag is on', (tester) async {
    await tester.pumpWidget(
      App(
        dependencies: AppDependencies.create(
          dataSource: const FakeArticleRemoteDataSource(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(AppKeys.articleList), findsOneWidget);
    expect(find.byKey(AppKeys.articleTile('0')), findsOneWidget);
  });

  testWidgets('shows feature disabled when the flag is off', (tester) async {
    await tester.pumpWidget(
      App(
        dependencies: AppDependencies.create(
          flags: const FakeFeatureFlags(enabled: {}),
          dataSource: const FakeArticleRemoteDataSource(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(AppKeys.featureDisabled), findsOneWidget);
    expect(find.byKey(AppKeys.articleList), findsNothing);
  });
}
