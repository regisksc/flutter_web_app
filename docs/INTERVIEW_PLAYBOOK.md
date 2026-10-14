# Interview playbook

## Workflow (nine steps)

| # | Step | Do |
|---|---|---|
| 0 | Orient | graphify, recall, baseline (analyze + test) |
| 1 | Grill + spec | grill-with-docs, then to-spec |
| 2 | Decide | ADR for hard-to-reverse decisions |
| 3 | Plan | plan mode; independent slices only |
| 4 | Red | failing tests, not compile errors |
| 5 | Green | small steps, hot reload; subagents sonnet-tier |
| 6 | Verify | analyze, coverage, goldens |
| 7 | Review | code-review; reject at least one edit with reason |
| 8 | Land | memory save, graphify --update, SHORTCUTS.md, NEXT.md |

## First 3 minutes, by format

- **Build a feature:** say the goal back in one line. Grill two questions. Write the spec (module, interface, 3 acceptance criteria). Then red test.
- **His repo:** read AGENTS.md or README first, then run analyze and tests. Ask which conventions win. Their conventions win.
- **Fix a bug:** reproduce with a failing test first. Name the root cause in one sentence before editing.
- **"Show me how you work":** open CONTEXT.md, show the nine-step table, run analyze. Then narrate one red-green cycle.
- **Twist (requirement changes mid-round):** update the spec's acceptance criteria first. Then ask what the change breaks.

## Speed vs day-to-day (talk track)

Say: "I took shortcuts to fit an hour. Here they are." Open SHORTCUTS.md and read three rows: fake data source, manual DI, Ahem goldens.
For each: what I did, why it is fast, the day-to-day version, and the trigger that makes me upgrade.
Close: "Shortcuts are deliberate and written down. Nothing is hidden."
