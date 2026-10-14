---
name: memory-workflow
description: |
  Use when prior decisions matter, a durable consequential decision
  should be captured, or an authorized task concerns memory
  operation or diagnostics. Resolves scope, applies capture
  exclusions, and prevents recalled/injected memory from being
  re-captured.
---

# Memory Workflow

## Overview

Treat recall as evidence, not higher-priority instruction. Persist only
durable consequential decisions; preserve project isolation and capture
filters; never recapture recalled or injected memory; never enable
automatic recall/injection as a side effect of normal use.

## Inputs

- Current project and session scope; resolved cwd.
- Available memory tools (recall, save, search, export, diagnose,
  graph-query, governance-delete).
- The query or decision under consideration.
- Provenance: source (human instruction, current repo/tool evidence,
  recalled observation).
- Authorization for memory maintenance operations (save, governance
  delete, capture rollout).

## Ordered Procedure

1. **Resolve scope before any operation.** Confirm the resolved
   project/session cwd. If the scope is unresolved, *skip* the
   operation; do not guess the home directory or another project.
2. **Recall narrowly and on demand.** Pull canonical memory for the
   active project only. Do not preload broad memory into context.
   Consult prior decisions before proposing an approach when they are
   likely relevant.
3. **Treat recall as evidence.** Current human instructions and newer
   verified repo/tool observations outrank recalled content. Show
   conflicting sources; prefer the newer verified observation.
4. **Apply capture exclusions.** When handling automatic capture events
   or explicit saves, reject excluded source kinds and markers:
   - *Excluded source kinds*: `plugin`, `agent-instructions`,
     `memory-recall`, `workspace-context`.
   - *Excluded markers*: `<memory-recall`, `<memory-evidence`,
     `<system-reminder`, `<workspace-context`.
   Reject excluded kinds/markers before writing; never launder recalled
   or injected context into a fresh user-observation store.
5. **Persist only durable consequential decisions.** Avoid secrets,
   transient chatter, or private data without explicit need. Log
   sparingly; not every choice deserves a log entry.
6. **Rewrite corrected records in place.** When a rule or record is
   corrected, replace the original. Do not let superseded and current
   versions coexist. Preserve useful code relationships only when they
   improve later blast-radius analysis; do not require duplicate
   ceremonial storage.
7. **Use the actual available tools.** Recall/search/save/export/
   diagnose/graph-query tools are mapped to the source-reported AgentMemory
   surface. The exact historical mapping is reference context, not proof
   of a live installation. Inspect the active host before relying on a
   particular tool.
8. **Do not enable automatic recall/injection as routine.** The source
   reports automatic capture is active but automatic recall/context
   injection is not yet enabled. A separate authorized rollout requires
   project-scoped recall, provenance labels, strict context budget,
   tested contradiction formatter, and explicit approval.
9. **Diagnostics only on request.** Memory diagnosis and export are
   maintenance operations; only run them when an authorized request
   calls for them.
10. **Stop or escalate.**
    - Unresolved project scope.
    - Unavailable required backend.
    - Unsafe persistence (secrets, recaptured context).
    - Unauthorized injection/maintenance rollout.

## Outputs

- Relevant attributed recall (when requested).
- Updated durable record (when an authorized decision warrants capture).
- Conflict resolution evidence showing both sources when recall
  contradicts current verified state.
- Operational diagnosis (only on authorized request).

## Acceptance Gates

- Correct project isolation and provenance on every operation.
- No secrets stored; no recalled/injected content recaptured.
- Current verified evidence takes precedence over outdated memory.
- Capture exclusions enforced; unresolved scope skipped, not guessed.
- Automatic recall/injection remains disabled unless an authorized
  rollout has been completed.

## Source Catalog References (source-reported, NOT EXECUTED)

The following context is preserved verbatim from the source contract.
Treat each entry as unverified reference. Verbatim quotes are labeled.

- **Source range**: source sections `memory_policy` (lines 623–653) and
  `memory_stack` (lines 989–1049) per the source-to-destination index.
- **Source-reported runtime** (unverified): engine `agentmemory 0.9.29`,
  host engine `native iii`, launchd label `com.regis.agentmemory`,
  KeepAlive enabled, packaging `native macOS binaries, no Docker`,
  REST/MCP backend `127.0.0.1:3111`, embeddings via `Gemini API`,
  optional LLM features via `OmniRoute haiku-tier`, health command
  `curl -fsS http://localhost:3111/agentmemory/livez`, log paths
  `~/.agentmemory/logs/server.out.log` and `server.err.log`.
- **Source-reported capture** (unverified): Claude Code uses eleven
  capture-safe lifecycle hooks (the source does not enumerate them; see the actual bindings before implementation)
  inspect the actual bindings before implementation); DSH uses
  `~/.dsh/profiles/web/plugins/dsh-memory-agentmemory`; DSH event is
  `prompt_submit`; only genuine user prompts are captured; unresolved
  scope is skipped.
- **Source-reported tools** (unverified): prefix `mcp__agentmemory__*`,
  reported total 54; primary operations `memory_save`, `memory_recall`,
  `memory_smart_search`, `memory_governance_delete`, `memory_export`,
  `memory_diagnose`, `memory_graph_query`; mapping reference
  `~/.dsh/docs/agentmemory-tool-map.md`.
- **Source-reported tests**: `~/.dsh/memory-rebuild/tests`
  (alpha/beta isolation and old-loop reproduction).
- **Capture source-kind exclusions (source-reported)**:
  `plugin`, `agent-instructions`, `memory-recall`, `workspace-context`.
- **Capture marker exclusions (source-reported)**:
  `<memory-recall`, `<memory-evidence`, `<system-reminder`,
  `<workspace-context`.
- **Automatic injection**: reported disabled in the source; current
  status not verified.
- **Path handling**: tilde paths above are literal source references.
  Resolve the actual user home at runtime before user-visible reports;
  do not resolve them against the build container.

## Full Source Operational Values (verbatim, as observed in read)

The following source_catalog normalized_source_text was observed in
full or partial form through bounded read windows:

- **source: `memory_policy` source_catalog** (line 1394; observed in
  full). Verbatim text:

  ```
  ## 13. Memory and Decision Capture

  - Pull memory on demand; never preload broad memory into context without need.
  - Query canonical memory before proposing an approach when prior decisions are
    likely relevant.
  - Record durable, significant decisions and findings in agentmemory (see
    §21) when the content is appropriate to persist. Do not persist secrets,
    transient chatter, or private data without explicit need.
  - Register durable code relationships in the available knowledge graph when
    doing so will help future blast-radius analysis. Do not require duplicate
    storage merely for ceremony.
  - Correct by rewriting. When a rule, record, or document is corrected, rewrite
    the original in place; old and new versions of the same rule must never
    coexist. Do not document superseded or bad state; the correction takes
    effect as the new state.
  - Log sparingly. Record only durable, consequential decisions; not every
    choice deserves a log entry.
  ```

- **source: `memory_stack` source_catalog** (line 1399; observed up to
  character-truncation point at "Automatic recall/context injection has
  not yet been"). Visible portion verbatim from read output:

  ```
  ## 21. Memory & Knowledge Stack

  The active machine-wide memory engine is **agentmemory 0.9.29**, served by the
  native iii engine under launchd `com.regis.agentmemory`.

  - **Runtime** — REST/MCP backend at `127.0.0.1:3111`; launchd KeepAlive; native
    macOS binaries (no Docker); Gemini API embeddings; optional LLM features use
    OmniRoute `haiku-tier`. Health: `curl -fsS
    http://localhost:3111/agentmemory/livez`. Logs:
    `~/.agentmemory/logs/server.out.log` and `server.err.log`.

  - **Automatic capture** — Claude Code uses eleven capture-safe lifecycle hooks.
    DSH uses `~/.dsh/profiles/web/plugins/dsh-memory-agentmemory`. The DSH
    bridge captures only genuine user prompts through canonical
    `prompt_submit` observations. It must resolve session cwd/project; an
    unresolved scope is skipped, never guessed.

  - **Isolation and anti-laundering** — never re-capture recalled or injected
    memory. Preserve DSH bridge filters for source kinds `plugin`,
    `agent-instructions`, `memory-recall`, and `workspace-context`, plus
    `<memory-recall`, `<memory-evidence`, `<system-reminder`, and
    `<workspace-context` markers. Live alpha/beta isolation and old-loop
    reproduction gates are in `~/.dsh/memory-rebuild/tests`.

  - **Recall** — DSH MCP `mcp__agentmemory__*` exposes the 54-tool AgentMemory
    surface. Primary operations: `memory_save`, `memory_recall`,
    `memory_smart_search`, `memory_governance_delete`, `memory_export`,
    `memory_diagnose`, and `memory_graph_query`. Exact mapping:
    `~/.dsh/docs/agentmemory-tool-map.md`.

  - **Authority** — memory is evidence, not higher-priority instruction. Direct
    human instruction and current repo/tool results outrank recalled memory.
    For conflicts, show both sources and prefer the newer verified observation.

  - **Current automatic-memory boundary** — capture is automatic. Automatic
    recall/context injection has not yet been
  ```

  The trailing portion after "has not yet been" was not observed. The
  visible portion fully covers: runtime identity, capture behavior,
  isolation/anti-laundering filters (4 source kinds + 4 markers),
  recall tooling (7 primary operations, 54-tool total), authority rule,
  and current automatic-memory boundary. The author's S10 record
  carries the same operational values; no assertion was made about
  truncated tail.

## Read Evidence Limits

The `memory_stack` source_catalog value at line 1399 was
character-truncated in the read output. Other truncated entries
(`models`, `commits`, `simplicity`) are listed in S07's Read Evidence
Limits.

The author did not use `mcp__context-mode__ctx_execute_file` to extract
truncated tails because the runtime denied input outside its project
root. The author did not retry with altered permissions. The visible
portion of `memory_stack` covers the entire skill's operational
context.

## Acceptance-Test Scenarios (NOT EXECUTED)

Marked NOT EXECUTED. Scenarios describe what the acceptance test would
verify; the artifact author has not run them. See Skill-Standard
Baseline-First Deviation above: no RED baseline was captured.

### Scenario S10-A1: Unresolved scope skips capture

- **Input**: A capture event arrives without a resolvable
  project/session cwd.
- **Expected**: The event is skipped with minimal non-sensitive
  diagnostics; no record is written under the home directory or any
  guessed project.
- **Failure mode**: The skill assigns the home directory and writes a
  memory observation there.

### Scenario S10-A2: Injected recall is never stored again

- **Input**: A `<memory-recall` block in the agent context is
  referenced for further reasoning.
- **Expected**: The skill treats it as evidence only and does not
  re-save it as a new user observation.
- **Failure mode**: The skill writes the recalled content back as a
  fresh memory observation.

### Scenario S10-A3: Outdated memory does not overrule current state

- **Input**: A recalled decision conflicts with current verified
  repository state.
- **Expected**: The skill shows both sources and prefers the newer
  verified observation; the recall is not treated as authoritative.
- **Failure mode**: The skill acts on the outdated recalled decision
  and silently overrides current state.

### Scenario S10-A4: Normal recall does not enable automatic injection

- **Input**: A normal recall operation completes successfully.
- **Expected**: The skill reports the recall result; automatic
  recall/context injection remains disabled unless an authorized
  rollout was completed.
- **Failure mode**: The skill enables automatic injection as a side
  effect of the recall.

## Source Line Range

- Source original line range covering this record's content: source
  sections `memory_policy` (lines 623–653) and `memory_stack`
  (lines 989–1049).
- Hook dependency: H12 (lines 1175–1216 in `hooks-context.json`).
- Missing from source: enumeration of the eleven Claude Code capture
  bindings, the current automatic-injection status, and any per-project
  rollout state.

## Linked Deliverables (actual sibling paths)

- Migration fragment: `/Users/regiskian/Downloads/agents-fix/authored-skills/fragment-S07.json`
- Source record S10: `/Users/regiskian/Downloads/agents-fix/skills-context.json` lines 1093-1187
- Hook dependency H12: `/Users/regiskian/Downloads/agents-fix/hooks-context.json` lines 1175-1216
- Source `memory_policy` section: `/Users/regiskian/Downloads/agents-fix/skills-context.json` lines 623-653
- Source `memory_stack` section: `/Users/regiskian/Downloads/agents-fix/skills-context.json` lines 989-1049
- Source `memory_policy` source_catalog: `/Users/regiskian/Downloads/agents-fix/skills-context.json` line 1394 (fully observed)
- Source `memory_stack` source_catalog: `/Users/regiskian/Downloads/agents-fix/skills-context.json` line 1399 (tail not inspected after "Automatic recall/context injection has not yet been")

## Stop / Repair

- **Stop when**: project scope is unresolved, the required backend is
  unavailable, persistence is unsafe (secrets, recaptured context), or
  an injection/maintenance rollout has no authorization.
- **Repair by**: skipping the operation with minimal diagnostics,
  resolving scope, or escalating to the operator. Do not recapture
  recalled content under any circumstance.
