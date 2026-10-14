/// Inputs to the article list BLoC.
sealed class ArticleListEvent {
  const ArticleListEvent();
}

/// Screen opened: load the first page.
final class ArticleListStarted extends ArticleListEvent {
  const ArticleListStarted();
}

/// User asked for the next page.
final class ArticleListMoreRequested extends ArticleListEvent {
  const ArticleListMoreRequested();
}

/// User retried after an error.
final class ArticleListRetried extends ArticleListEvent {
  const ArticleListRetried();
}
