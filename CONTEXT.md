# Outsmart kit: ubiquitous language

One context: the starter kit. The example feature is the article list. Use these terms in code names, tests, and conversation.

| Term | Meaning | Not to be confused with | Where in code |
|---|---|---|---|
| Article | One item in the list: id, title, summary. Domain entity. | Model (the JSON shape) | lib/features/example/domain/entities/ |
| ArticlePage | One page of Articles plus the next cursor. | A screen or route | lib/features/example/domain/entities/ |
| Cursor | Opaque token saying where the next page starts. Null means no more pages. | Page number or offset | ArticleRepository.fetchPage argument |
| Page size | How many Articles one page asks for (limit). | Page (the set of Articles) | fetchPage(limit) |
| Result | Either a success value or a Failure. Returned by use cases and repositories. | Exception | lib/core/error/result.dart |
| Failure | A value for a known failure: NetworkFailure, ServerFailure, UnexpectedFailure. | Exception | lib/core/error/failure.dart |
| Feature flag | A named on/off switch (enum Flag) read through FeatureFlags. | Environment config or build flavor | lib/core/flags/feature_flags.dart |
| Use case | One app action, e.g. GetArticlePage. Calls one repository. | Bloc event handler | lib/features/example/domain/usecases/ |
| Repository | Domain interface (ArticleRepository) that returns Result. | Data source | domain/repositories/ (interface), data/repositories/ (impl) |
| Data source | Talks to the outside world. Throws exceptions. ArticleRemoteDataSource and its Fake. | Repository | data/datasources/ |
| Model vs Entity | Model: JSON-shaped, fromJson and toJson, lives in data. Entity: pure domain object. | Each other | data/models/ vs domain/entities/ |
| Bloc state names | ArticleListLoading, ArticleListData, ArticleListEmpty, ArticleListError. Sealed. | Widget state | presentation/bloc/ |
| AppKeys | Stable string keys for widget finders in tests. | Localization keys | lib/core/testing/keys.dart |
| Design system | Tokens and components with no business logic. | Feature widgets | lib/core/design_system/ |
| Fake | In-memory stand-in for a data source, used by the app and tests. | Mock (mocktail) | FakeArticleRemoteDataSource |

## Relationships

- An **ArticlePage** holds many **Articles** and at most one **Cursor**.
- A **Use case** calls one **Repository**. A **Repository** calls one or more **Data sources**.
- A **Data source** throws exceptions. The **Repository** turns them into **Failures** inside a **Result**.
- A **Bloc** calls **Use cases** and emits Bloc states.

## Example dialogue

> **Dev:** "When the list hits the end, do we ask for page 0 again?"
> **Lead:** "No. The **Cursor** on the last **ArticlePage** is null, so we stop. A **Page size** change does not reset the **Cursor**."
> **Dev:** "And a network error?"
> **Lead:** "The **Data source** throws. The **Repository** returns a **Failure** in a **Result**. The **Bloc** emits ArticleListError. Nothing throws past the repository."

## Flagged ambiguities

- "page" was used for both the set of Articles and the page number. Resolved: ArticlePage is the set, Cursor is the position. Never use a page number.
- "model" was used for both the JSON shape and the domain object. Resolved: Model is data-layer only; Entity is domain.

## Short links (Bitly use case)

| Term | Meaning | Not to be confused with | Where in code |
|---|---|---|---|
| Short link | A long URL plus its short code, created by the user | Article | features/short_links/domain/entities/short_link.dart |
| Short code | 7-char base62 id, or the user's alias | Cursor | ShortLink.code |
| Alias | Optional custom short code, 3-20 chars, unique, case-sensitive | Title | domain/rules/short_link_rules.dart |
| Click | One resolve of a code; increments clickCount | Page view | ResolveShortLink |
| Resolve | Look up a code and count a click (simulated redirect) | Open in a browser | ShortLinkRepository.resolve |
| Backend | In-process service behind ShortLinkRemoteDataSource | A real server | data/datasources/in_memory_short_link_backend.dart |
