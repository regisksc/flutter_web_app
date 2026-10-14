# hooks

Claude Code-compatible hooks for this interview kit. Three scripts, all bash, all under 10 s.

- pre_tool_guard.sh (PreToolUse): blocks git commit/push/init/add/stage, branch changes, and edits to pubspec.yaml dependencies and the coverage threshold. Exit 2 with a reason on stderr. Create .allow-deps in the project root to lift the dependency block.
- stop_gate.sh (Stop): advisory. Runs flutter analyze with an 8 s budget and reminds you when docs/work/TRACE.md was not touched this session. Never blocks.
- session_start.sh (SessionStart): prints the AGENTS.md INDEX table and reminds you to run graphify and recall AgentMemory.

hooks.json is the DSH/Cordis input (bare event map wrapped in matcher groups). The same hooks also live in .claude/settings.json for Claude Code.

Loading into DSH is the user's step: merge docs/dsh-hook-row.yml into ~/.dsh/cordis.patch.yml, then restart DSH through the restart-dsh gate. Nothing in this folder edits ~/.dsh.

Tests: run tool/test_hooks.sh.
