import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_app/core/testing/keys.dart';
import 'package:flutter_web_app/core/url_opener.dart';
import 'package:flutter_web_app/features/short_links/domain/entities/short_link.dart';
import 'package:flutter_web_app/features/short_links/presentation/bloc/short_links_bloc.dart';
import 'package:flutter_web_app/features/short_links/presentation/bloc/short_links_event.dart';
import 'package:flutter_web_app/features/short_links/presentation/bloc/short_links_state.dart';
import 'package:flutter_web_app/features/short_links/presentation/widgets/short_link_tile.dart';
import 'package:mocktail/mocktail.dart';

class _MockShortLinksBloc extends MockBloc<ShortLinksEvent, ShortLinksState>
    implements ShortLinksBloc {}

/// Records what it opened.
class _FakeUrlOpener implements UrlOpener {
  final opened = <String>[];

  @override
  void open(String url) => opened.add(url);
}

void main() {
  setUpAll(() => registerFallbackValue(const ShortLinksStarted()));

  late _MockShortLinksBloc bloc;
  late _FakeUrlOpener opener;
  final link = ShortLink(
    code: 'abc',
    longUrl: 'https://example.com/original',
    createdAt: DateTime.utc(2026),
    clickCount: 0,
  );

  Future<void> pumpTile(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<ShortLinksBloc>.value(
            value: bloc,
            child: ShortLinkTile(link: link, opener: opener),
          ),
        ),
      ),
    );
  }

  testWidgets('open opens the long URL and counts a click', (tester) async {
    bloc = _MockShortLinksBloc();
    opener = _FakeUrlOpener();
    await pumpTile(tester);

    await tester.tap(find.byKey(AppKeys.openButton('abc')));

    expect(opener.opened, ['https://example.com/original']);
    verify(() => bloc.add(const ShortLinkOpened('abc'))).called(1);
  });

  testWidgets('tapping the short url text opens the long url too', (
    tester,
  ) async {
    bloc = _MockShortLinksBloc();
    opener = _FakeUrlOpener();
    await pumpTile(tester);

    await tester.tap(find.text('https://sho.rt/abc'));

    expect(opener.opened, ['https://example.com/original']);
    verify(() => bloc.add(const ShortLinkOpened('abc'))).called(1);
  });
}
