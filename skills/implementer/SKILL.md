---
name: implementer
description: Builds or resyncs an orchestrator skill from an existing HARNESS_DESIGN.md (§13+§14; HARNESS_DESIGN_PATH). Scaffolds the target skill directory via skill-creator, embeds §14 diagrams, packages. Also handles rules-only harnesses (AGENTS.md / .cursor/rules). Not for writing the design (designer) or smoke-validation (validator).
---

# Harness implementer

Turn **`harness-designs/<orchestrator>/HARNESS_DESIGN.md`** (§13 + §14) into a runnable **orchestrator skill** under `skills/<orchestrator>/`. Works as the second step after **`designer`**. Layout: `../designer/references/harness-design-layout.md`.

## Input contract (from designer)

| Section | Required | Output in orchestrator |
|---------|----------|-------------------------|
| §13 | Yes | `SKILL.md`, templates, `AGENTS.md` row |
| §14 | Yes (or derive + backfill) | `assets/workflow.mermaid.md`, `## Workflow diagrams` in `SKILL.md` |

See `references/parse-design-input.md` and `../designer/references/design-implementer-handoff.md`.

## When to use

- User finished `designer` and wants the orchestrator built
- Design exists at `HARNESS_DESIGN_PATH` or `harness-designs/<orchestrator>/HARNESS_DESIGN.md` with §13

Do **not** use for: writing `HARNESS_DESIGN.md` (`designer`), feedback-driven pipeline fixes (`enhancer` — except when enhancer delegates sync here), running the orchestrator, or editing delegate skills without explicit request.

## Prerequisites

- `skills/skill-creator/` available
- **Python 3.8+** installed and on PATH (stdlib only — no `pip` packages). The `skill-creator` scripts (`init_skill.py`, `package_skill.py`, `quick_validate.py`) are run via an interpreter that the agent must **detect before invoking**: try `python3 --version`, then `python --version`, then `py -3 --version`; use the first that reports `Python 3.`. If none works, **stop and tell the user to install Python 3 before proceeding** — do not run any scaffold/package step. Windows: `python3` is usually absent from PATH — use `python` or `py -3` (e.g. `py -3 skills/skill-creator/scripts/init_skill.py …`).
- Design file readable at `HARNESS_DESIGN_PATH` (required for multi-harness repos). If unset, resolve from §13 orchestrator name: `harness-designs/<name>/HARNESS_DESIGN.md`. Do not use repo-root `HARNESS_DESIGN.md` (catalog pointer only).

## Workflow

### 1. Load and validate design (§13 + §14)

1. Read `HARNESS_DESIGN.md`.
2. Parse §13 — `references/parse-section-13.md`.
3. Parse §14 — `references/parse-design-input.md`.
4. If §13 missing → stop; run `designer`.
5. If §13 `rules-only` → follow `references/rules-only.md` to completion (artifacts in the target repo, update `harness-designs/README.md` Status per step 6's catalog rule, report the handoff), then **STOP — do not run steps 2–7**. No skill-creator, no `init_skill.py`, no `assets/workflow.mermaid.md`, no packaging. The rest of this workflow is orchestrator-skill mode only.
6. If §14 missing → derive Mermaid per `../designer/references/mermaid-diagrams.md`, then **append §14 to `HARNESS_DESIGN.md`**.
7. If orchestrator exists → **update in place** without asking when invoked with `UPDATE_IN_PLACE=true` (the enhancer/validator repair loop sets this so it does not stall). Otherwise ask: update in place or abort.
8. Run consistency checks in `parse-design-input.md` (§3 ↔ §14 batch flow, §6 ↔ bundle diagram).

### 2. Load skill-creator (orchestrator-skill mode only)

**Steps 2–7 are orchestrator-skill mode only. Skip them entirely if §13 mode is `rules-only`** — step 1.5 already handled that path via `references/rules-only.md` and stopped.

Read `skills/skill-creator/SKILL.md`.

### 3. Scaffold orchestrator

Resolve the **orchestrator home** from §13 (`Orchestrator home`). Default `skills/` in this repo; may be an external skills repo or install dir. Scaffold there:

```bash
# <home> = §13 Orchestrator home (default: skills)
# Use the detected Python 3 interpreter: python3 (POSIX) | python | py -3 (Windows).
python3 skills/skill-creator/scripts/init_skill.py <orchestrator-name> --path <home>
```

Remove init example files if present. Confirm the §6 delegates are available (installed in `~/.claude|.cursor/skills` or co-located) at `<home>`; if not, flag the gap in the handoff (do not copy delegate bodies).

### 4. Materialize §14 (Mermaid)

**Before** writing prose workflow steps:

1. Create `assets/workflow.mermaid.md` — paste full §14 content (all mermaid blocks + headings): a `# Workflow diagrams — <orchestrator>` heading, then the bundle / batch-flow / gates mermaid blocks under `##` subheadings.
2. In `SKILL.md`, add section **`## Workflow diagrams`**:
   - Embed the **batch flow** `flowchart TD` from §14 (required)
   - Optional: one-line pointer to `assets/workflow.mermaid.md` for bundle + gate diagrams
3. If §14 was derived in step 1, ensure `HARNESS_DESIGN.md` on disk is updated so designer and implementer stay aligned.

### 5. Populate orchestrator (§13 + design)

| File | Source |
|------|--------|
| `SKILL.md` | §3, §7, §8, §13 steps + **§14 embed** (step 4) |
| `references/harness-spec.md` | Condensed §3–§9 + pointer to bundled design |
| `references/skill-delegation.md` | §6 + §13 delegate rules |
| `references/HARNESS_DESIGN.md` | **Generated read-only copy of source design** (ships with skill; banner header, never hand-edited — see fail-closed rules) |
| `assets/workflow.mermaid.md` | §14 (step 4) |
| Other `assets/*` | §12/§13 templates |

Do **not** copy delegate skill bodies. Use `references/orchestrator-file-checklist.md`.

Orchestrator YAML `description`: from §13 AGENTS.md index line.

### 6. Register and package

```bash
# Use the detected Python 3 interpreter: python3 (POSIX) | python | py -3 (Windows).
python3 skills/skill-creator/scripts/package_skill.py <home>/<orchestrator-name> skills/skill-creator/dist
```

Always update `harness-designs/README.md` (the design lives in this repo regardless of home) — **create it from the Catalog template in `../designer/references/harness-design-layout.md` if missing**, and set this orchestrator's row Status to `built`. Update **this repo's** `AGENTS.md` skill index (§13 line) only when the orchestrator home **is** this repo; if home is an external repo, add the index line to **that repo's** `AGENTS.md` instead and note it in the handoff.

### 7. Handoff

Report:

- `skills/<orchestrator-name>/`
- `assets/workflow.mermaid.md` created/updated
- `HARNESS_DESIGN.md` §14 backfilled (yes/no)
- Zip path under `skill-creator/dist/`
- Runtime trigger phrase from §13
- Delegate gaps (e.g. external skills)

**Next:** hand off to `validator` to smoke-run the orchestrator on one §3 item (worktree + §7 gates + human sign-off) before it is trusted in production:

```text
Load validator with:
  HARNESS_DESIGN_PATH=harness-designs/<orchestrator>/HARNESS_DESIGN.md
```

## Fail-closed rules

- Never ship orchestrator without `assets/workflow.mermaid.md` and batch diagram in `SKILL.md`.
- Never skip backfilling §14 on the design file when it was derived.
- Never modify delegate skills unless user explicitly requests.
- The bundled `skills/<orchestrator>/references/HARNESS_DESIGN.md` is a **generated, read-only copy** — the canonical source is `harness-designs/<orchestrator>/HARNESS_DESIGN.md`. Never hand-edit the bundled copy; regenerate it by re-running the implementer from canonical. Top the copy with a banner: `<!-- GENERATED COPY — do not edit. Canonical: harness-designs/<orchestrator>/HARNESS_DESIGN.md -->`.

## Relationship to other skills

| Skill | Role |
|-------|------|
| `designer` | Produces §13 + §14 |
| `implementer` | This skill |
| `validator` | Smoke-runs the built orchestrator before runtime; routes failures back via `enhancer` |
| `enhancer` | Patches design/meta; delegates sync re-run to this skill |
| `skill-creator` | Init + package |
| Orchestrator | Runtime (step 3 of pipeline) |

## Resources

| Path | Purpose |
|------|---------|
| `references/parse-design-input.md` | §13 + §14 extraction |
| `references/parse-section-13.md` | §13 table fields |
| `references/orchestrator-file-checklist.md` | Includes Mermaid files |
| `references/rules-only.md` | No orchestrator path |
| `assets/orchestrator-SKILL.template.md` | SKILL skeleton |
| `../designer/references/mermaid-diagrams.md` | Diagram rules |
| `../designer/references/design-implementer-handoff.md` | Shared checklist |
