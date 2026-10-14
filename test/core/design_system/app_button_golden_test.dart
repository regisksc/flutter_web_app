import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_app/app/app_theme.dart';
import 'package:flutter_web_app/core/design_system/components/app_button.dart';

void main() {
  testWidgets('app button golden', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Center(
            child: AppButton(label: 'Continue', onPressed: () {}),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(AppButton),
      matchesGoldenFile('goldens/app_button.png'),
    );
  });
}
