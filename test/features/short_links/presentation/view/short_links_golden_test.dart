import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_app/app/app_theme.dart';
import 'package:flutter_web_app/features/short_links/domain/entities/short_link.dart';
import 'package:flutter_web_app/features/short_links/presentation/bloc/short_links_bloc.dart';
import 'package:flutter_web_app/features/short_links/presentation/bloc/short_links_event.dart';
import 'package:flutter_web_app/features/short_links/presentation/bloc/short_links_state.dart';
import 'package:flutter_web_app/features/short_links/presentation/view/short_links_view.dart';

/// Passes when at most [tolerance] of the pixels differ. Linux CI anti-aliases text a few pixels
/// differently from macOS; a real layout change is far above 0.1%.
class _TolerantComparator extends LocalFileComparator {
  _TolerantComparator(super.testFile, this.tolerance);

  final double tolerance;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    if (result.passed || result.diffPercent <= tolerance) return true;
    final error = await generateFailureOutput(result, golden, basedir);
    throw FlutterError(error);
  }
}

class _MockShortLinksBloc extends MockBloc<ShortLinksEvent, ShortLinksState>
    implements ShortLinksBloc {}

void main() {
  testWidgets('short links data state golden', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final previous = goldenFileComparator as LocalFileComparator;
    goldenFileComparator = _TolerantComparator(
      previous.basedir.resolve('short_links_golden_test.dart'),
      0.001,
    );
    addTearDown(() => goldenFileComparator = previous);

    final bloc = _MockShortLinksBloc();
    final state = ShortLinksData(
      items: [
        ShortLink(
          code: 'aB3xY9z',
          longUrl: 'https://example.com/a/very/long/path?utm=1',
          createdAt: DateTime.utc(2026),
          clickCount: 3,
        ),
        ShortLink(
          code: 'promo',
          longUrl: 'https://example.com/sale',
          createdAt: DateTime.utc(2026),
          clickCount: 1,
        ),
      ],
    );
    whenListen(
      bloc,
      const Stream<ShortLinksState>.empty(),
      initialState: state,
    );

    await tester.pumpWidget(
      BlocProvider<ShortLinksBloc>.value(
        value: bloc,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: ShortLinksView()),
        ),
      ),
    );
    await tester.pump();

    await expectLater(
      find.byType(ShortLinksView),
      matchesGoldenFile('goldens/short_links_data.png'),
    );
  });
}
