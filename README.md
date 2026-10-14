# Outsmart Flutter interview kit

A small Flutter app that shows how to build a feature fast, cleanly, and test-first: clean architecture, feature-first folders, BLoC, and a design system.

It is a starter for a 1-hour live-coding round. The example feature is a cursor-paginated article list.

## 60-second quickstart

```bash
flutter pub get
flutter analyze
flutter test --coverage
flutter run -d <ios-simulator-id>
```

You should see: "No issues found!" from analyze, all tests green, and the article list on the simulator.

## Where to look

- AGENTS.md: rules and commands for agents and humans
- CONTEXT.md: the words this codebase uses
- SHORTCUTS.md: what was cut for speed, and the day-to-day version
- docs/INTERVIEW_PLAYBOOK.md: how to run the round, with a "first 3 minutes" script per format
- docs/NEW_FEATURE.md: the step list for adding a feature

## Use case: Bitly-style shortener

lib/features/short_links is the product feature: paste a URL, get a short URL in a result card, type again. The backend is in-process (docs/adr/0001-in-process-backend.md); spec in docs/specs/short-links.md.
