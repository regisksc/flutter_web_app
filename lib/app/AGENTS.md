# lib/app: rules

- Owns App widget, bootstrap (manual DI wiring), theme (app_theme.dart), and feature-flag gating in app.dart.
- Bootstrap is the only place that builds concrete data sources and repositories.
- Changes to bootstrap, main, DI, or const globals need a hot restart. Queue them; restart once.
- Flag gating: read FeatureFlags, never a raw bool. Default is FakeFeatureFlags.
- No business logic here. No feature imports except to wire routes.
- Test: widget test for App; keep app.dart free of logic that needs a branch test.
