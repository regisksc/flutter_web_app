# Shortcuts

Every deliberate shortcut in this kit. Each has a matching "// ponytail:" comment in code. Upgrade when the trigger happens.

| Shortcut | Risk | Day-to-day version | Trigger to upgrade |
|---|---|---|---|
| Fake in-memory data source instead of real HTTP | Real network errors, timeouts, and auth are untested | Real HTTP data source behind the same interface, with a client mock in tests | First real backend, or any need for real error codes |
| const FakeFeatureFlags instead of remote flags | Flags never change at runtime | Remote flag provider behind FeatureFlags | Product needs flags changed without a release |
| Manual DI instead of get_it | Wiring hand-written in bootstrap; grows messy past about five features | get_it or a DI package in bootstrap.dart | More than about five features or shared singletons |
| Goldens use Ahem test font | Platform-stable but not pixel-realistic; hides font bugs | Golden with the real app font, per platform | Typography or brand review starts |
| lib/main.dart excluded from coverage | Startup bugs are not caught by unit tests | Test bootstrap with a fake runApp in a widget test | Startup logic grows beyond one call |
| No l10n | Strings are hard-coded English | flutter_localizations plus ARB files | Any second language |
| No router (single screen) | No deep links or back-stack logic | go_router via MaterialApp.router | Second screen with navigation |
| Patrol stub only | No E2E coverage on device | Patrol configured per patrol_test/README.md | Release gate, or interviewer asks for E2E |
| Marionette debug-only | Release builds cannot be driven by the agent; web builds are not covered | n/a -- keep the guard | Shipping release + need to drive it |
| iOS simulator only | Android not verified | Add Android target and emulator run | Android is in scope |
| In-memory backend (no network, no persistence) | Links vanish on restart; no real redirects | Real HTTP data source behind ShortLinkRemoteDataSource | A real server exists (docs/adr/0001-in-process-backend.md) |
| No auth, users, expiry, rate limit, URL reachability check | Anyone can create unlimited links, even dead URLs | Auth token + server-side limits + link checker | Product needs accounts or abuse protection |
| Clipboard only (no browser open of the long URL) | Open only counts a click | url_launcher to open the long URL | Real redirect behaviour is required |
