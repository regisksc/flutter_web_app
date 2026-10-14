# lib/features/example: reference feature

Cursor-paginated article list. Reference implementation, not a template to copy blindly.

- Demonstrates: Article/ArticlePage entities, ArticleRepository.fetchPage(cursor, limit) -> Result, GetArticlePage use case, fake remote data source that throws, repository converting exceptions to Failure, sealed Loading/Data/Empty/Error bloc states, AppKeys, one golden.
- Do not add behavior here for a new feature. Scaffold a new one.
- Change the fake data to change demo content; do not change the cursor contract without an ADR.
- Layers: see domain/, data/, presentation/ AGENTS.md files.
