# domain: rules

- Pure Dart. Imports only dart:core and lib/core/error. No Flutter, no data, no presentation.
- entities/: Article, ArticlePage. Immutable, Equatable if you compare them.
- repositories/: ArticleRepository interface. fetchPage(Cursor?, int limit) returns Result<ArticlePage>.
- usecases/: GetArticlePage. One repository call. Returns Result. No try/catch here.
- Unit test every use case with a mocktail repository mock under test/features/example/domain/.
