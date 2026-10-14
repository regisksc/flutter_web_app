# Outsmart Flutter kit: agent contract

Live-coding interview starter kit. Clean architecture, feature-first, BLoC. Keep everything simple and fast.
Nested AGENTS.md files add rules for their folder. The closest file wins. Root rules apply everywhere.

## Project map

| Path | What lives there |
|---|---|
| lib/main.dart | entry point; calls bootstrap |
| lib/app/ | App widget, bootstrap (manual DI), theme, feature-flag gating |
| lib/core/ | shared Failure/Result, feature flags, AppKeys, design system |
| lib/features/example/ | reference feature: cursor-paginated article list (domain, data, presentation) |
| lib/features/short_links/ | product feature: Bitly-style shortener (web: real redirect server in tool/, iOS: in-memory fake) |
| test/ | unit, bloc, widget, golden tests mirroring lib/ |
| integration_test/ | app flow on the iOS simulator |
| patrol_test/ | E2E placeholder only (Patrol not set up) |
| docs/ | playbook, principles, specs, ADRs, NEW_FEATURE steps, templates, TRACE |
| tool/, hooks/, .github/, .agents/, config/ | scripts, hooks, CI, agent skills, MCP wiring |
| CONTEXT.md | ubiquitous language. Use these terms in code, tests, and talk |
| SHORTCUTS.md | every deliberate shortcut, with its risk and day-to-day version |

## INDEX

| path | file | scope |
|---|---|---|
| ./ | AGENTS.md | repo-wide rules, commands, workflow, definition of done |
| lib/ | AGENTS.md | code layout, layer rules, comment and lint rules for all lib code |
| lib/app/ | AGENTS.md | app shell, bootstrap and DI wiring, theme, flag gating |
| lib/core/ | AGENTS.md | shared Failure/Result, flags, AppKeys; no feature imports |
| lib/core/design_system/ | AGENTS.md | tokens and components; no business logic, no feature imports |
| lib/features/ | AGENTS.md | feature-first rules; how features are added and isolated |
| lib/features/example/ | AGENTS.md | reference feature: article list; what it demonstrates |
| lib/features/example/domain/ | AGENTS.md | entities, repository interfaces, use cases; pure Dart only |
| lib/features/example/data/ | AGENTS.md | data sources, models, repository impl; converts exceptions to Failure |
| lib/features/example/presentation/ | AGENTS.md | BLoC, view, widgets; depends on use cases only |
| lib/features/short_links/ | AGENTS.md | product feature: Bitly-style shortener |
| lib/features/short_links/domain/ | AGENTS.md | short link entities, rules, use cases; pure Dart |
| lib/features/short_links/data/ | AGENTS.md | in-memory backend, models, repository impl; exceptions become Failure |
| lib/features/short_links/presentation/ | AGENTS.md | ShortLinksBloc, form + result card + list |
| test/ | AGENTS.md | test layout, pyramid levels, golden rules, no test edits to pass |
| integration_test/ | AGENTS.md | local iOS simulator flow tests; not for unit logic |
| patrol_test/ | AGENTS.md | E2E placeholder; setup status and steps |
| docs/ | AGENTS.md | docs layout, specs, ADRs, trace log; template copies are not indexed |
| hooks/ | AGENTS.md | git and agent hook scripts; do not weaken gates |

If your harness did not auto-load nested AGENTS.md, read it before editing in that folder.
Templates under docs/templates/** are copies for scaffolding. They are excluded from the index.

## Commands

```bash
flutter pub get
flutter analyze                    # must end with: No issues found!
flutter test --coverage            # unit, bloc, widget, golden
tool/coverage_check.sh             # >=80% line coverage per changed lib file
flutter test test/core/design_system test/features/example/presentation/view/article_list_golden_test.dart test/features/short_links/presentation/view/short_links_golden_test.dart
flutter test --update-goldens      # ONLY with explicit human approval
flutter test integration_test -d <ios-simulator-id>   # local only
flutter build ios --simulator --debug --no-codesign
flutter build web --release --pwa-strategy=none   # tool/watch_web.sh does this on every change; tool/redirect_server.py serves build/web + the shortener API on :8877
tool/e2e_public.sh                 # public DNS + shorten + 302 forwarding, against the funnel URL
tool/watch_web.sh                  # keep build/web (and so the public URL) on the latest lib/
tool/check_agents_index.sh         # AGENTS.md index matches the files
tool/test_hooks.sh
tool/new_feature.sh <name>         # scaffold a feature from docs/templates/feature
/opt/homebrew/bin/graphify         # code graph; run --update after landing
```

## Workflow (nine steps, existing skills only)

Shrink a step when the task is short. Never drop one.

| # | Step | Do | Output |
|---|---|---|---|
| 0 | Orient | graphify, AgentMemory recall, run baseline (analyze + test) | baseline numbers |
| 1 | Grill + spec | grill-with-docs, then to-spec | docs/specs/<name>.md |
| 2 | Decide | ADR via grill-with-docs when the decision is hard to reverse | docs/adr/NNNN-slug.md |
| 3 | Plan | DSH plan mode; independent slices only | short plan with slices |
| 4 | Red | tdd, dart-add-unit-test, flutter-add-widget-test | failing tests (red, not compile errors) |
| 5 | Green | subagents ALWAYS model "sonnet-tier"; root stays on strong model; small steps, hot reload | passing tests |
| 6 | Verify | dart-run-static-analysis, tests with coverage, golden | analyze + coverage + goldens |
| 7 | Review | code-review skill; human rejects at least one edit, with reason | review notes |
| 8 | Land | AgentMemory save, graphify --update, SHORTCUTS.md, NEXT.md | docs updated, nothing committed |

## Test pyramid

1. Unit: domain use cases, data mappers, Failure/Result. Fast, pure Dart.
2. bloc_test: every BLoC transition, one test per state.
3. Widget: each view state, AppKeys finders, design-system components.
4. Golden: one per screen, Ahem font, in goldens/ next to the test.
5. Local integration and Patrol: iOS simulator only. Not in the default test run.

## Rules

- Scope lock: change only what the spec names. Out-of-scope edits fail review.
- No new dependencies without asking first.
- Tests are the contract. Never edit a test to make it pass. Fix the code, or ask.
- Every deliberate shortcut: a comment ```// ponytail: <ceiling and upgrade trigger>``` AND a row in SHORTCUTS.md.
- No commits, staging or pushes unless the human explicitly orders it (then a task branch + PR, never a direct push to main, never force-push).
- Never print secrets, tokens, or .env values.
- Failures are values. Exceptions never cross layers (see lib/AGENTS.md).
- If the interviewer shares a repo, THEIR conventions win over this kit.

## Narration protocol

- Before each action: INTENT / LOOKING / DECISION (and what was rejected) / EVIDENCE / RISK. Max 5 lines.
- Append each block to docs/work/TRACE.md.
- After each edit: one plain-English note per changed file: what it does, why this way, what breaks it, which line to change for the likely follow-up.
- Subagents end with CHANGED / WHY / TESTS / DOUBTS.

## Hot-reload rule

- While coding, keep the app running on the iOS simulator.
- Use the Dart MCP tools (launch_app, hot_reload, get_runtime_errors, get_widget_tree) and flutter_agent_lens after EVERY change.
- Prefer hot reload. Changes that need a hot restart (const, globals, initState, main, DI wiring) are queued, applied together at the next safe point, then one hot restart checks all of them.
- Marionette is installed (marionette_flutter, debug-only guard in main.dart; docs/OPTIONAL.md). DSH cannot load new MCP servers without a restart, so call Marionette or Patrol MCP tools from bash (run mcporter daemon start first): ```mcporter --config config/mcporter.json call marionette.<tool>```.

## Round-completion rule

Before calling any step or session complete:
1. Run mcp__decisions__decide: purpose child_result, one noul question "do all acceptance criteria have passing tests and no out-of-scope edits?". Low strictness: advisory only. Retry once on timeout.
2. On the final round, also run mcp__jev__jev_decide (see the jev-second-opinion skill). Advisory only.
3. Report the answers. Never let them block the work.

## Definition of done

- flutter analyze: "No issues found!"
- flutter test --coverage passes; >=80% per changed lib file
- goldens pass (no update without approval)
- tool/check_agents_index.sh passes
- every acceptance criterion has a passing test
- SHORTCUTS.md, NEXT.md, docs/work/TRACE.md updated
- nothing staged or committed
- round-completion rule run and reported
