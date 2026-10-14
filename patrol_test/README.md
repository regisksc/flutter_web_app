# Patrol E2E (not set up)

Status: NOT set up. This kit has only this README and a stub.

Why not set up: Patrol needs the patrol dependency and a native RunnerUITests target. That is a dependency change, so it needs human approval. Setup was not attempted within the interview-kit time budget.

E2E is local-only, iOS simulator. Not in the default test run.

## Steps to set up (human-approved)

1. Read skill patrol-setup. Follow its steps for iOS and the pubspec patrol block.
2. Add the RunnerUITests target in ios/ (native).
3. Rename example_flow_test.dart.tmpl to example_flow_test.dart and make it pass on the simulator.
4. Write further flows with patrol-write-test. Organize with patrol-test-architecture.

config/mcporter.json wires patrol_mcp for agent calls: ```mcporter --config config/mcporter.json call patrol.<tool>```.
