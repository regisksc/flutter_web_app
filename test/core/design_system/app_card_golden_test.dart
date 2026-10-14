import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_app/app/app_theme.dart';
import 'package:flutter_web_app/core/design_system/components/app_card.dart';

void main() {
  testWidgets('app card golden', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              child: AppCard(child: Text('Card content')),
            ),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(AppCard),
      matchesGoldenFile('goldens/app_card.png'),
    );
  });
}
