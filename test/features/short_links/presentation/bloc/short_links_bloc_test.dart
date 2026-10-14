import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_app/core/error/failure.dart';
import 'package:flutter_web_app/core/error/result.dart';
import 'package:flutter_web_app/features/short_links/domain/entities/short_link.dart';
import 'package:flutter_web_app/features/short_links/domain/entities/short_link_page.dart';
import 'package:flutter_web_app/features/short_links/domain/usecases/create_short_link.dart';
import 'package:flutter_web_app/features/short_links/domain/usecases/list_short_links.dart';
import 'package:flutter_web_app/features/short_links/domain/usecases/resolve_short_link.dart';
import 'package:flutter_web_app/features/short_links/presentation/bloc/short_links_bloc.dart';
import 'package:flutter_web_app/features/short_links/presentation/bloc/short_links_event.dart';
import 'package:flutter_web_app/features/short_links/presentation/bloc/short_links_state.dart';
import 'package:mocktail/mocktail.dart';

class MockListShortLinks extends Mock implements ListShortLinks {}

class MockCreateShortLink extends Mock implements CreateShortLink {}

class MockResolveShortLink extends Mock implements ResolveShortLink {}

final _a = ShortLink(
  code: 'aaa',
  longUrl: 'https://a.example',
  createdAt: DateTime.utc(2026),
  clickCount: 0,
);
final _b = ShortLink(
  code: 'bbb',
  longUrl: 'https://b.example',
  createdAt: DateTime.utc(2025),
  clickCount: 0,
);

void main() {
  late MockListShortLinks list;
  late MockCreateShortLink create;
  late MockResolveShortLink resolve;

  ShortLinksBloc makeBloc() => ShortLinksBloc(
    listShortLinks: list,
    createShortLink: create,
    resolveShortLink: resolve,
  );

  setUp(() {
    list = MockListShortLinks();
    create = MockCreateShortLink();
    resolve = MockResolveShortLink();
  });

  void stubList({String? cursor, required Result<ShortLinkPage> result}) {
    when(() => list(cursor: cursor, limit: 10)).thenAnswer((_) async => result);
  }

  blocTest<ShortLinksBloc, ShortLinksState>(
    'started emits data when the first page has links',
    setUp: () => stubList(
      result: Ok(ShortLinkPage(items: [_a], nextCursor: '1')),
    ),
    build: makeBloc,
    act: (bloc) => bloc.add(const ShortLinksStarted()),
    expect: () => [
      const ShortLinksLoading(),
      ShortLinksData(items: [_a], nextCursor: '1'),
    ],
  );

  blocTest<ShortLinksBloc, ShortLinksState>(
    'started emits empty when the first page has no links',
    setUp: () => stubList(result: const Ok(ShortLinkPage(items: []))),
    build: makeBloc,
    act: (bloc) => bloc.add(const ShortLinksStarted()),
    expect: () => [const ShortLinksLoading(), const ShortLinksEmpty()],
  );

  blocTest<ShortLinksBloc, ShortLinksState>(
    'started emits error when the first page fails',
    setUp: () => stubList(result: const Err(NetworkFailure())),
    build: makeBloc,
    act: (bloc) => bloc.add(const ShortLinksStarted()),
    expect: () => [
      const ShortLinksLoading(),
      const ShortLinksError(NetworkFailure()),
    ],
  );

  blocTest<ShortLinksBloc, ShortLinksState>(
    'retried loads the first page again',
    setUp: () => stubList(result: Ok(ShortLinkPage(items: [_a]))),
    seed: () => const ShortLinksError(NetworkFailure()),
    build: makeBloc,
    act: (bloc) => bloc.add(const ShortLinksRetried()),
    expect: () => [
      const ShortLinksLoading(),
      ShortLinksData(items: [_a]),
    ],
  );

  blocTest<ShortLinksBloc, ShortLinksState>(
    'more requested appends the next page',
    setUp: () {
      stubList(
        cursor: '1',
        result: Ok(ShortLinkPage(items: [_b])),
      );
    },
    seed: () => ShortLinksData(items: [_a], nextCursor: '1'),
    build: makeBloc,
    act: (bloc) => bloc.add(const ShortLinksMoreRequested()),
    expect: () => [
      ShortLinksData(items: [_a], nextCursor: '1', isLoadingMore: true),
      ShortLinksData(items: [_a, _b]),
    ],
  );

  blocTest<ShortLinksBloc, ShortLinksState>(
    'more requested keeps the items when the next page fails',
    setUp: () => stubList(cursor: '1', result: const Err(NetworkFailure())),
    seed: () => ShortLinksData(items: [_a], nextCursor: '1'),
    build: makeBloc,
    act: (bloc) => bloc.add(const ShortLinksMoreRequested()),
    expect: () => [
      ShortLinksData(items: [_a], nextCursor: '1', isLoadingMore: true),
      ShortLinksData(
        items: [_a],
        nextCursor: '1',
        actionFailure: NetworkFailure(),
      ),
    ],
  );

  blocTest<ShortLinksBloc, ShortLinksState>(
    'more requested does nothing without a next cursor',
    setUp: () => stubList(
      cursor: '1',
      result: const Ok(ShortLinkPage(items: [])),
    ),
    seed: () => ShortLinksData(items: [_a]),
    build: makeBloc,
    act: (bloc) => bloc.add(const ShortLinksMoreRequested()),
    expect: () => <ShortLinksState>[],
    verify: (_) => verifyNever(
      () => list(
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ),
  );

  blocTest<ShortLinksBloc, ShortLinksState>(
    'submitted prepends the new link to the list',
    setUp: () {
      when(
        () => create(longUrl: 'https://a.example', alias: null),
      ).thenAnswer((_) async => Ok(_a));
    },
    seed: () => ShortLinksData(items: [_b]),
    build: makeBloc,
    act: (bloc) =>
        bloc.add(const ShortLinkSubmitted(longUrl: 'https://a.example')),
    expect: () => [
      ShortLinksData(items: [_b], isCreating: true),
      ShortLinksData(items: [_a, _b]),
    ],
  );

  blocTest<ShortLinksBloc, ShortLinksState>(
    'submitted on an empty list shows the first link',
    setUp: () {
      when(
        () => create(longUrl: 'https://a.example', alias: 'aaa'),
      ).thenAnswer((_) async => Ok(_a));
    },
    seed: () => const ShortLinksEmpty(),
    build: makeBloc,
    act: (bloc) => bloc.add(
      const ShortLinkSubmitted(longUrl: 'https://a.example', alias: 'aaa'),
    ),
    expect: () => [
      ShortLinksData(items: [_a]),
    ],
  );

  blocTest<ShortLinksBloc, ShortLinksState>(
    'a failed create keeps the items and sets the action failure',
    setUp: () {
      when(() => create(longUrl: 'ftp://x', alias: null)).thenAnswer(
        (_) async => const Err(
          ValidationFailure('URL must start with http:// or https://'),
        ),
      );
    },
    seed: () => ShortLinksData(items: [_b]),
    build: makeBloc,
    act: (bloc) => bloc.add(const ShortLinkSubmitted(longUrl: 'ftp://x')),
    expect: () => [
      ShortLinksData(items: [_b], isCreating: true),
      ShortLinksData(
        items: [_b],
        actionFailure: ValidationFailure(
          'URL must start with http:// or https://',
        ),
      ),
    ],
  );

  blocTest<ShortLinksBloc, ShortLinksState>(
    'opened replaces the link with its new click count',
    setUp: () {
      when(
        () => resolve('aaa'),
      ).thenAnswer((_) async => Ok(_a.copyWith(clickCount: 1)));
    },
    seed: () => ShortLinksData(items: [_a, _b]),
    build: makeBloc,
    act: (bloc) => bloc.add(const ShortLinkOpened('aaa')),
    expect: () => [
      ShortLinksData(items: [_a.copyWith(clickCount: 1), _b]),
    ],
  );

  blocTest<ShortLinksBloc, ShortLinksState>(
    'opened keeps the list and sets the action failure when resolve fails',
    setUp: () {
      when(
        () => resolve('aaa'),
      ).thenAnswer((_) async => const Err(NotFoundFailure()));
    },
    seed: () => ShortLinksData(items: [_a]),
    build: makeBloc,
    act: (bloc) => bloc.add(const ShortLinkOpened('aaa')),
    expect: () => [
      ShortLinksData(items: [_a], actionFailure: NotFoundFailure()),
    ],
  );
}
