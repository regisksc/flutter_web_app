import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_app/core/design_system/components/app_button.dart';
import 'package:flutter_web_app/core/error/failure.dart';
import 'package:flutter_web_app/core/testing/keys.dart';
import 'package:flutter_web_app/features/short_links/domain/entities/short_link.dart';
import 'package:flutter_web_app/features/short_links/presentation/bloc/short_links_bloc.dart';
import 'package:flutter_web_app/features/short_links/presentation/bloc/short_links_event.dart';
import 'package:flutter_web_app/features/short_links/presentation/bloc/short_links_state.dart';
import 'package:flutter_web_app/features/short_links/presentation/view/short_links_view.dart';
import 'package:mocktail/mocktail.dart';

class MockShortLinksBloc extends MockBloc<ShortLinksEvent, ShortLinksState>
    implements ShortLinksBloc {}

final _a = ShortLink(
  code: 'aaa',
  longUrl: 'https://a.example',
  createdAt: DateTime.utc(2026),
  clickCount: 0,
);

void main() {
  setUpAll(() => registerFallbackValue(const ShortLinksStarted()));

  late MockShortLinksBloc bloc;

  setUp(() {
    bloc = MockShortLinksBloc();
  });

  Future<void> pumpView(
    WidgetTester tester,
    ShortLinksState state, {
    Stream<ShortLinksState>? stream,
  }) async {
    whenListen(
      bloc,
      stream ?? const Stream<ShortLinksState>.empty(),
      initialState: state,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<ShortLinksBloc>.value(
            value: bloc,
            child: const ShortLinksView(),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('loading shows the spinner', (tester) async {
    await pumpView(tester, const ShortLinksLoading());

    expect(find.byKey(AppKeys.shortLinksLoading), findsOneWidget);
  });

  testWidgets('empty shows the message and the form', (tester) async {
    await pumpView(tester, const ShortLinksEmpty());

    expect(find.byKey(AppKeys.shortLinksEmpty), findsOneWidget);
    expect(find.byKey(AppKeys.urlField), findsOneWidget);
    expect(find.byKey(AppKeys.shortenButton), findsOneWidget);
  });

  testWidgets('error shows the error view and retry dispatches a retry', (
    tester,
  ) async {
    await pumpView(tester, const ShortLinksError(NetworkFailure()));

    expect(find.byKey(AppKeys.shortLinksError), findsOneWidget);
    await tester.tap(find.byKey(AppKeys.retryButton));
    verify(() => bloc.add(const ShortLinksRetried())).called(1);
  });

  testWidgets(
    'data shows a tile with copy and open buttons and a load-more button',
    (tester) async {
      await pumpView(tester, ShortLinksData(items: [_a], nextCursor: '1'));

      expect(find.byKey(AppKeys.shortLinksList), findsOneWidget);
      expect(find.byKey(AppKeys.shortLinkTile('aaa')), findsOneWidget);
      expect(find.byKey(AppKeys.copyButton('aaa')), findsOneWidget);
      expect(find.byKey(AppKeys.openButton('aaa')), findsOneWidget);
      expect(find.byKey(AppKeys.shortLinksLoadMore), findsOneWidget);
    },
  );

  testWidgets('a failed action shows the inline error text', (tester) async {
    await pumpView(
      tester,
      ShortLinksData(items: [_a], actionFailure: const NetworkFailure()),
    );

    expect(find.byKey(AppKeys.actionError), findsOneWidget);
    expect(find.text('No internet connection'), findsOneWidget);
  });

  testWidgets('shorten is disabled while a link is being created', (
    tester,
  ) async {
    await pumpView(tester, ShortLinksData(items: [_a], isCreating: true));

    final button = tester.widget<AppButton>(find.byKey(AppKeys.shortenButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('shorten sends the URL with no alias when the alias is empty', (
    tester,
  ) async {
    await pumpView(tester, const ShortLinksEmpty());

    await tester.enterText(find.byKey(AppKeys.urlField), 'https://a.example');
    await tester.tap(find.byKey(AppKeys.shortenButton));

    verify(
      () => bloc.add(const ShortLinkSubmitted(longUrl: 'https://a.example')),
    ).called(1);
  });

  testWidgets('shorten sends the typed alias', (tester) async {
    await pumpView(tester, const ShortLinksEmpty());

    await tester.enterText(find.byKey(AppKeys.urlField), 'https://a.example');
    await tester.enterText(find.byKey(AppKeys.aliasField), 'promo');
    await tester.tap(find.byKey(AppKeys.shortenButton));

    verify(
      () => bloc.add(
        const ShortLinkSubmitted(longUrl: 'https://a.example', alias: 'promo'),
      ),
    ).called(1);
  });

  testWidgets('a created link appears in the list', (tester) async {
    final controller = StreamController<ShortLinksState>();
    addTearDown(controller.close);
    await pumpView(tester, const ShortLinksEmpty(), stream: controller.stream);

    controller.add(ShortLinksData(items: [_a]));
    await tester.pump();
    await tester
        .pump(); // stream event needs a second pump after an initial pump

    expect(find.byKey(AppKeys.shortLinkTile('aaa')), findsOneWidget);
  });
}
