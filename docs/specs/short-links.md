# Spec: short_links (Bitly-style shortener)

## Goal

Paste a long URL, get a short URL (https://sho.rt/<code>), see it in a result card, type another, and see all links with click counts.

## Assumed constraints

- Code: 7 chars base62, generated; optional alias 3-20 chars [A-Za-z0-9_-], case-sensitive, unique; reserved: api, admin, links, health.
- Long URL: http/https, host required, max 2048 chars. Same long URL without alias creates a NEW link (like Bitly).
- List: newest first, cursor = offset string, page size 10. Open = resolve + click count +1.
- No auth, no expiry, no analytics beyond clickCount. Backend is in-process (see docs/adr/0001-in-process-backend.md).

## Module changes

- lib/features/short_links/{domain,data,presentation}/...: new feature (same shape as example).
- lib/core/error/failure.dart: ValidationFailure, ConflictFailure, NotFoundFailure.
- lib/core/flags/feature_flags.dart: Flag.shortLinks. lib/core/testing/keys.dart: short link keys.
- lib/app/{bootstrap,app}.dart, lib/main.dart: wiring; main enables Flag.shortLinks.

## Interfaces (signatures)

```dart
abstract interface class ShortLinkRepository {
  Future<Result<ShortLink>> create({required String longUrl, String? alias});
  Future<Result<ShortLinkPage>> list({String? cursor, required int limit});
  Future<Result<ShortLink>> resolve(String code);
}
abstract interface class ShortLinkRemoteDataSource { // JSON maps; throws Validation/Conflict/NotFound/ServerException
  Future<Map<String, dynamic>> createLink({required String longUrl, String? alias});
  Future<Map<String, dynamic>> listLinks({String? cursor, required int limit});
  Future<Map<String, dynamic>> resolveLink(String code);
}
```

## Acceptance criteria

- [x] Bad URL or alias gives ValidationFailure without hitting the repository (rules + CreateShortLink tests).
- [x] Taken alias gives ConflictFailure; unknown code gives NotFoundFailure (backend + repository tests).
- [x] Shorten shows the result card and clears the URL field so the user can type again (test/app/short_links_flow_test.dart).
- [x] Open increments the click count (bloc, backend and flow tests).
- [x] List is newest first with cursor pagination and load more (backend and bloc tests).

## Out of scope

Auth, expiry, real redirects, analytics, rate limiting, custom domains.

## Open questions

- Real backend: who owns it and which HTTP package is allowed? (needs dependency approval)
