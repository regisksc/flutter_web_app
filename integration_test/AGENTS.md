# integration_test: rules

- app_flow_test.dart runs the app on the iOS simulator. Local only; not in the default test run.
- Run: flutter test integration_test -d <ios-simulator-id>.
- Use AppKeys finders. Do not use text matchers for things that have a key.
- Keep flows short: launch, see list, scroll to end, see empty or error state.
- Do not put unit logic here. Use test/ instead.
- Use the fake data source; no network in integration tests.
