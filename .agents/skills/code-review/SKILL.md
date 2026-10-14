---
name: code-review
description: "Review the changes since a fixed point (commit, branch, tag, or merge-base) along two axes: Standards (does the code follow this repo's documented coding standards?) and Spec (does the code match what the originating issue/spec asked for?). Runs both reviews in parallel sub-agents and reports them side by side. Use when the user wants to review a branch, a PR, work-in-progress changes, or asks to \"review since X\"."
---

Two-axis review of the diff between `HEAD` and a fixed point the user supplies:

- **Standards**: does the code conform to this repo's documented coding standards?
- **Spec**: does the code faithfully implement the originating issue / spec?

Both axes run as **parallel sub-agents** so they don't pollute each other's context, then this skill aggregates their findings.

The issue tracker should have been provided to you. If `docs/agents/issue-tracker.md` is missing, tell the user to run `/setup-matt-pocock-skills`.

## Process


## S05 independent-review overlay (applied 20260922, source-grounded per migration manifest)

## Inputs

- Spec or acceptance criteria for the candidate.
- Actual candidate diff and identity (commit, branch, base SHA, head SHA, or a pinned fixed point).
- Command-level verification evidence (exact gate commands and decisive observed results).
- Active repository, Ketchup configuration, and the configured remote review route (if any).
- The applicable review route precedence (C02-review-timing).

## Ordered conditional procedure

### 1. Determine the applicable review route before adding a reviewer
If the route is the local implementation-child route: proceed with one short-lived nonrecursive independent reviewer.

If the route is a configured remote AI reviewer that supplies independent review after publication: rely on that route and do not duplicate equivalent local pre-push review unless explicitly required.

If both routes appear to apply without an approved precedence (C02-review-timing): surface the conflict at the publication boundary. Do not silently waive a gate.

**Completion criterion:** the chosen route is recorded with its precedence justification.

### 2. Run the Standards + Spec axes against the actual candidate
Reuse the installed two-axis structure (Standards + Spec). For each axis:
- Standards: does the candidate conform to the repository's documented coding standards (the active language's installed standards skill)?
- Spec: does the candidate faithfully implement the spec / acceptance criteria?

Evaluate against:
- Spec or acceptance criteria.
- Existing architecture.
- Root cause (for fixes) or goal (for new behavior).
- Scope discipline (surgical-change rules from S01).
- DRY/YAGNI (Ponytail ladder).
- Required coverage (focused check exists in existing test infrastructure for non-trivial logic).
- Actual verification evidence (gates run with decisive observed results).

**Completion criterion:** each axis produces a concrete finding list or a clean-pass statement.

### 3. Use one short-lived nonrecursive reviewer for the local route
The local implementation-child route uses one short-lived, nonrecursive reviewer. Do not give the reviewer the implementation conversation. Give the reviewer the spec, diff, identity, and verification evidence.

**Completion criterion:** the reviewer evidence is bound to a candidate identity, not to the implementation conversation.

### 4. Return concrete missing requirements to the same implementation child
When the reviewer identifies missing requirements or defects, return them to the same implementation child (and the same worktree where viable). The parent accepts after the applicable review passes.

**Completion criterion:** a reviewer finding is either accepted and closed by the same child or escalated with concrete looping evidence.

### 5. Bind review to the candidate
Review evidence applies only to its candidate. After edits to the candidate, refresh affected review and verification rather than deeply re-reviewing unchanged work.

**Completion criterion:** when the candidate changes, the re-review scope is limited to affected changes; unchanged work is not deeply re-reviewed.

### 6. Do not duplicate equivalent local pre-push review
A configured remote AI reviewer may provide independent review after publication. Do not duplicate equivalent local pre-push review unless explicitly required. Do not remove mandatory Ketchup gates by assumption.

**Completion criterion:** any local pre-push reviewer is justified by an explicit route gap, not by assumption.

### 7. Do not bypass Ketchup to resolve a contradiction
When a workflow contradiction appears (e.g., remote post-publication review + mandatory Ketchup + requested local pre-push), surface the contradiction. Do not bypass Ketchup.

**Completion criterion:** a contradiction is recorded at the publication boundary and resolved by route, not by skipping a guardrail.

### 8. Discover Ketchup configuration
Source-reported Ketchup configuration: 20+ validators active by default; deny-lists at `.ketchup/deny-list.project.txt` and `.ketchup/deny-list.local.txt`; CLI executable `/Users/regiskian/.local/bin/ketchup`. These are source-reported unverified. Discover the actual current configuration.

**Completion criterion:** the actually-discovered Ketchup configuration is named before any review verdict is recorded.

## Outputs

- Standards-axis findings or clean-pass.
- Spec-axis findings or clean-pass.
- Aggregate reviewer verdict bound to the candidate identity.
- Route-decision record (local reviewer, remote reviewer, or escalated contradiction).
- For missing requirements: a return-to-same-child record with concrete edits to apply.

## Acceptance scenarios (NOT EXECUTED)

Source-grounded scenarios; not run in this artifact-authoring session.

| ID | Input | Expected | Failure |
|----|-------|----------|---------|
| S05-A1 | Candidate code is edited after a reviewer verdict. | Affected review is refreshed; unchanged work is not deeply re-reviewed. | The same candidate is deeply re-reviewed end-to-end. |
| S05-A2 | A configured remote AI reviewer exists and is the established route. | No equivalent local pre-push reviewer is added. | An equivalent local pre-push reviewer duplicates the configured route. |
| S05-A3 | A workflow contradiction (remote + Ketchup + requested local pre-push) appears without an approved precedence. | The contradiction is surfaced at the publication boundary. Ketchup is not bypassed. | Ketchup is bypassed or a gate is silently waived. |
| S05-A4 | An implementation child finishes a slice. | One short-lived nonrecursive reviewer is dispatched with spec, diff, and verification evidence. The reviewer verdict is bound to the candidate. | The reviewer is given the implementation conversation, or no candidate identity is recorded. |
| S05-A5 | Reviewer identifies a missing requirement. | The finding returns to the same implementation child with a concrete edit instruction. The parent accepts after the affected re-review passes. | The finding is implemented by a new child that duplicates ownership of the same scope. |

## Stop / repair

Stop and escalate when:
- Conflicting review timing (C02-review-timing) cannot be resolved.
- No actual candidate or evidence is available.
- Unavailable required reviewer (mandatory Ketchup or configured remote reviewer) and no fallback approved.
- Unresolved critical finding.

Repair in scope:
- A failing gate pauses publication, not problem-solving.
- Each retry changes implementation or approach with new evidence.
- Do not weaken gates, bypass hooks, or fabricate passing results (C04-guardrail-maintenance).

## Operational context carried verbatim (source-reported unverified)

- Ketchup source-reported: `Impartial validator subagent for every nontrivial commit, with 20+ validators; current configuration must be discovered.`
- Judgment limit: `Review and atomicity judgments are not deterministic merely because an LLM reviewer is launched by a hook.`
- Ketchup CLI: `/Users/regiskian/.local/bin/ketchup` (source-reported path, unverified at write time).
- Ketchup deny-lists: `.ketchup/deny-list.project.txt` and `.ketchup/deny-list.local.txt` (source-reported, unverified).
- C02-review-timing: no per-repository precedence rule in the source; resolve at publication.

### 1. Pin the fixed point

Whatever the user said is the fixed point (a commit SHA, branch name, tag, `main`, `HEAD~5`, etc.). If they didn't specify one, ask for it.

Capture the diff command once: `git diff <fixed-point>...HEAD` (three-dot, so the comparison is against the merge-base). Also note the list of commits via `git log <fixed-point>..HEAD --oneline`.

Before going further, confirm the fixed point resolves (`git rev-parse <fixed-point>`) and the diff is non-empty. A bad ref or empty diff should fail here, not inside two parallel sub-agents.

### 2. Identify the spec source

Look for the originating spec, in this order:

1. Issue references in the commit messages (`#123`, `Closes #45`, GitLab `!67`, etc.), fetched via the workflow in `docs/agents/issue-tracker.md`.
2. A path the user passed as an argument.
3. A spec file under `docs/`, `specs/`, or `.scratch/` matching the branch name or feature.
4. If nothing is found, ask the user where the spec is. If they say there isn't one, the **Spec** sub-agent will skip and report "no spec available".

### 3. Identify the standards sources

Anything in the repo that documents how code should be written, such as `CODING_STANDARDS.md` or `CONTRIBUTING.md`.

On top of whatever the repo documents, the Standards axis always carries the **smell baseline** below: a fixed set of Fowler code smells (_Refactoring_, ch.3) that applies even when a repo documents nothing. Two rules bind it:

- **The repo overrides.** A documented repo standard always wins; where it endorses something the baseline would flag, suppress the smell.
- **Always a judgement call.** Each smell is a labelled heuristic ("possible Feature Envy"), never a hard violation. Like any standard here, skip anything tooling already enforces.

Each smell reads *what it is* → *how to fix*; match it against the diff:

- **Mysterious Name**: a function, variable, or type whose name doesn't reveal what it does or holds. → rename it; if no honest name comes, the design's murky.
- **Duplicated Code**: the same logic shape appears in more than one hunk or file in the change. → extract the shared shape, call it from both.
- **Feature Envy**: a method that reaches into another object's data more than its own. → move the method onto the data it envies.
- **Data Clumps**: the same few fields or params keep travelling together (a type wanting to be born). → bundle them into one type, pass that.
- **Primitive Obsession**: a primitive or string standing in for a domain concept that deserves its own type. → give the concept its own small type.
- **Repeated Switches**: the same `switch`/`if`-cascade on the same type recurs across the change. → replace with polymorphism, or one map both sites share.
- **Shotgun Surgery**: one logical change forces scattered edits across many files in the diff. → gather what changes together into one module.
- **Divergent Change**: one file or module is edited for several unrelated reasons. → split so each module changes for one reason.
- **Speculative Generality**: abstraction, parameters, or hooks added for needs the spec doesn't have. → delete it; inline back until a real need shows.
- **Message Chains**: long `a.b().c().d()` navigation the caller shouldn't depend on. → hide the walk behind one method on the first object.
- **Middle Man**: a class or function that mostly just delegates onward. → cut it, call the real target direct.
- **Refused Bequest**: a subclass or implementer that ignores or overrides most of what it inherits. → drop the inheritance, use composition.

### 4. Spawn both sub-agents in parallel

**Standards sub-agent prompt** should include:

- The full diff command and commit list.
- The list of standards-source files you found in step 3, **plus the smell baseline from step 3** pasted in full (the sub-agent has no other access to it).
- The brief: "Report, per file/hunk where relevant, (a) every place the diff violates a documented standard: cite the standard (file + the rule); and (b) any baseline smell you spot: name it and quote the hunk. Distinguish hard violations from judgement calls: documented-standard breaches can be hard, but baseline smells are always judgement calls, and a documented repo standard overrides the baseline. Skip anything tooling enforces. Under 400 words."

**Spec sub-agent prompt** should include:

- The diff command and commit list.
- The path or fetched contents of the spec.
- The brief: "Report: (a) requirements the spec asked for that are missing or partial; (b) behaviour in the diff that wasn't asked for (scope creep); (c) requirements that look implemented but where the implementation looks wrong. Quote the spec line for each finding. Under 400 words."

If the spec is missing, skip the Spec sub-agent and note this in the final report.

### 5. Aggregate

Present the two reports under `## Standards` and `## Spec` headings, verbatim or lightly cleaned. Do **not** merge or rerank findings, because the two axes are deliberately separate (see _Why two axes_).

End with a one-line summary: total findings per axis, and the worst issue _within each axis_ (if any). Don't pick a single winner across axes: that's the reranking the separation exists to prevent.

## Why two axes

A change can pass one axis and fail the other:

- Code that follows every standard but implements the wrong thing → **Standards pass, Spec fail.**
- Code that does exactly what the issue asked but breaks the project's conventions → **Spec pass, Standards fail.**

Reporting them separately stops one axis from masking the other.