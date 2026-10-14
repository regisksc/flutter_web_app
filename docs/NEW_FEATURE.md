# New feature: exact steps

1. **Grill.** Run grill-with-docs on the feature. Update CONTEXT.md with new terms.
2. **Spec.** Run to-spec into docs/specs/<name>.md: module changes, interfaces, acceptance criteria (testable bullets).
3. **Scaffold.** Run ```tool/new_feature.sh <name>```. It copies docs/templates/feature into lib/features/<name> and test/.
4. **Domain first.** Entity, repository interface, use case returning Result<T>. Pure Dart.
5. **Red tests first.** Use case tests fail for the right reason. Not compile errors.
6. **Data.** Datasource throws exceptions. Repository converts to Failure inside Result. Mapper tests.
7. **Bloc.** Sealed states loading, data, empty, error. bloc_test per transition.
8. **View.** Widget test per state. AppKeys keys. Design-system components only. One golden.
9. **Flag.** Add a value to Flag. Gate in lib/app/app.dart. FakeFeatureFlags default.
10. **Verify and land.** analyze, coverage, goldens. Then SHORTCUTS.md, NEXT.md, TRACE.md, AgentMemory save.

## How Result and Failure are used

```dart
// data: repository converts exceptions into values
on NetworkException { return const Err(NetworkFailure()); }
// domain: use case passes it through
Future<Result<ArticlePage>> call(Cursor? cursor, int limit) => _repo.fetchPage(cursor, limit);
// bloc: a Result is handled, never thrown
result.fold((f) => emit(ArticleListError(f)), (p) => emit(ArticleListData(p)));
```

## How feature flags are used

```dart
// lib/core/flags/feature_flags.dart: enum Flag { newListHeader }
// lib/app/app.dart: gate, never a raw bool
if (flags.isEnabled(Flag.newListHeader)) return const NewHeader();
```

## How AppKeys are used

```dart
// lib/core/testing/keys.dart
static const articleList = Key('article_list');
// widget test
expect(find.byKey(AppKeys.articleList), findsOneWidget);
```

## Rule: native seams (Rive, Unity-style) - NO code in this kit

Native engine seams use a typed message contract, a fake host, and a fallback widget.
Test the seam without the real engine. The fallback renders when the host is missing.

## Rule: feature-creation rules live here

Scaffold code (templates) stays minimal. Process rules live in this file, not in scaffold code.
