# Agent skills for this kit

Each skill is a real folder copied in (no symlinks). Use it to drive an agent live in the interview.

- graphify: builds the code graph so the agent can navigate the repo fast.
- grill-with-docs: challenges a plan against CONTEXT.md and ADRs before code is written.
- grill-me: interviews you to surface hidden assumptions in a prompt or plan.
- tdd-workflow: enforces red-green-refactor for every new behaviour.
- verification-loop: runs analyze, tests, and checks as a repeatable gate.
- ponytail: pushes the agent toward the smallest solution that works.
- memory-workflow: when to recall and save durable decisions in AgentMemory.
- code-review: reviews the diff against the spec and the repo standards.
- dart-add-unit-test: writes package:test unit tests for pure Dart logic.
- dart-run-static-analysis: runs dart analyze and applies safe automatic fixes.
- dart-fix-runtime-errors: reads the live runtime error and fixes the failing line.
- flutter-add-widget-test: writes WidgetTester tests for a view's states and taps.
- flutter-add-integration-test: adds integration_test flows for simulator runs.
- flutter-apply-architecture-best-practices: keeps UI, logic, and data layers separate.
- flutter-fix-layout-issues: fixes overflow and unbounded-constraint errors.
- patrol-setup: first-time Patrol E2E setup. Not installed in this kit yet.
- patrol-write-test: writes Patrol E2E tests. Not used until Patrol is set up.
- patrol-test-architecture: modular layout for a larger Patrol suite. Reference only.
- dart-flutter-patterns (everything-claude-code, MIT): idiomatic Dart and Flutter patterns.
- flutter-dart-code-review (everything-claude-code, MIT): Flutter-specific review checklist.
- tdd (mattpocock/skills): short TDD loop the agent can follow in a live session.
- to-spec (mattpocock/skills): turns a grilled idea into a spec file in docs/specs/.
- improve-codebase-architecture (mattpocock/skills): spots shallow modules and seams to refactor.
- domain-modeling (mattpocock/skills): names entities and terms before code is written.
- codebase-design (mattpocock/skills): reviews module boundaries and dependency direction.
