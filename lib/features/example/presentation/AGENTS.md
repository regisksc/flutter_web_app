# presentation: rules

- bloc/: ArticleListBloc with sealed states ArticleListLoading, ArticleListData, ArticleListEmpty, ArticleListError. Calls GetArticlePage only.
- view/: screens. Read Bloc state, render, dispatch events. Use design-system components only.
- widgets/: small pieces used by view. Stateless where possible.
- bloc_test one test per transition. Widget test one per state, finders via AppKeys.
- One golden per screen, in goldens/ next to the golden test. Ahem font.
- No imports from data/.
