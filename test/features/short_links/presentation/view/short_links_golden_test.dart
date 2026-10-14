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

class _MockShortLinksBloc extends MockBloc<ShortLinksEvent, ShortLinksState>
    implements ShortLinksBloc {}

void main() {
  testWidgets('short links data state golden', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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
