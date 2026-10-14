import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_app/app/app_theme.dart';
import 'package:flutter_web_app/core/design_system/components/error_view.dart';

void main() {
  testWidgets('error view golden', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: ErrorView(message: 'Something went wrong', onRetry: () {}),
        ),
      ),
    );

    await expectLater(
      find.byType(ErrorView),
      matchesGoldenFile('goldens/error_view.png'),
    );
  });
}
