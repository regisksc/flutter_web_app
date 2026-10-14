import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_app/core/testing/keys.dart';
import 'package:flutter_web_app/features/short_links/domain/entities/short_link.dart';
import 'package:flutter_web_app/features/short_links/presentation/bloc/short_links_bloc.dart';
import 'package:flutter_web_app/features/short_links/presentation/bloc/short_links_event.dart';
import 'package:flutter_web_app/features/short_links/presentation/bloc/short_links_state.dart';
import 'package:flutter_web_app/features/short_links/presentation/widgets/short_link_tile.dart';
import 'package:mocktail/mocktail.dart';

class MockShortLinksBloc extends MockBloc<ShortLinksEvent, ShortLinksState>
    implements ShortLinksBloc {}

ShortLink _link({int clicks = 0}) => ShortLink(
  code: 'aaa',
  longUrl: 'https://a.example/very/long/path',
  createdAt: DateTime.utc(2026),
  clickCount: clicks,
);

void main() {
  setUpAll(() => registerFallbackValue(const ShortLinksStarted()));

  late MockShortLinksBloc bloc;

  setUp(() {
    bloc = MockShortLinksBloc();
    whenListen(
      bloc,
      const Stream<ShortLinksState>.empty(),
      initialState: const ShortLinksEmpty(),
    );
  });

  Future<void> pumpTile(WidgetTester tester, ShortLink link) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<ShortLinksBloc>.value(
            value: bloc,
            child: ShortLinkTile(link: link),
          ),
        ),
      ),
    );
  }

  testWidgets('shows the short url, the long url and a singular click count', (
    tester,
  ) async {
    await pumpTile(tester, _link(clicks: 1));

    expect(find.text('https://sho.rt/aaa'), findsOneWidget);
    expect(find.text('https://a.example/very/long/path'), findsOneWidget);
    expect(find.text('1 click'), findsOneWidget);
  });

  testWidgets('shows a plural click count for other counts', (tester) async {
    await pumpTile(tester, _link(clicks: 3));

    expect(find.text('3 clicks'), findsOneWidget);
  });

  testWidgets('copy puts the short url on the clipboard', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await pumpTile(tester, _link());

    await tester.tap(find.byKey(AppKeys.copyButton('aaa')));
    await tester.pump();

    expect(copied, 'https://sho.rt/aaa');
  });

  testWidgets('open dispatches ShortLinkOpened for the code', (tester) async {
    await pumpTile(tester, _link());

    await tester.tap(find.byKey(AppKeys.openButton('aaa')));

    verify(() => bloc.add(const ShortLinkOpened('aaa'))).called(1);
  });
}
