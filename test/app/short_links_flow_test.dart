import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_app/app/app.dart';
import 'package:flutter_web_app/app/bootstrap.dart';
import 'package:flutter_web_app/core/flags/feature_flags.dart';
import 'package:flutter_web_app/core/testing/keys.dart';

void main() {
  testWidgets('user shortens a URL, sees the result, and can type again', (
    tester,
  ) async {
    await tester.pumpWidget(
      App(
        dependencies: AppDependencies.create(
          flags: const FakeFeatureFlags(enabled: {Flag.shortLinks}),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(AppKeys.urlField), findsOneWidget);
    expect(find.byKey(AppKeys.latestResult), findsNothing);

    await tester.enterText(
      find.byKey(AppKeys.urlField),
      'https://example.com/a/very/long/path',
    );
    await tester.tap(find.byKey(AppKeys.shortenButton));
    await tester.pumpAndSettle();

    expect(find.byKey(AppKeys.latestResult), findsOneWidget);
    expect(find.textContaining('https://sho.rt/'), findsWidgets);
    expect(
      tester.widget<TextField>(find.byKey(AppKeys.urlField)).controller!.text,
      isEmpty,
    );

    // Type again: a second link goes to the top of the list.
    await tester.enterText(
      find.byKey(AppKeys.urlField),
      'https://example.com/second',
    );
    await tester.tap(find.byKey(AppKeys.shortenButton));
    await tester.pumpAndSettle();
    expect(find.text('https://example.com/second'), findsOneWidget);

    // Open counts a click.
    await tester.tap(find.byIcon(Icons.open_in_new).first);
    await tester.pumpAndSettle();
    expect(find.text('1 click'), findsOneWidget);
  });
}
