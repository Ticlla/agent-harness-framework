---
name: enhancer
description: Improves meta pipeline skills and/or one harness instance from user feedback or failure signals (VALIDATION_REPORT fail, implementer preflight, design↔skill drift, runtime mismatch). Writes EnhancementBrief, patches targeted files, delegates designer / implementer / validator re-runs. Not for greenfield design or first-time build.
---

# Harness enhancer

Close the **feedback loop** on the harness framework. This skill improves:

| Layer | What it is | Typical paths |
|-------|------------|---------------|
| **Meta** | Skills that build any harness | `skills/designer/`, `skills/implementer/` |
| **Instance** | One concrete harness | `harness-designs/<orchestrator>/`, `skills/<orchestrator>/` |

It **does not** replace greenfield design (`designer`), first-time build (`implementer`), or runtime execution (`<orchestrator>`). It **orchestrates** targeted edits and optional re-runs of those skills.

See `references/classification.md` for meta vs instance examples.

## When to use

- User gives corrections over one or many messages about a harness or the pipeline
- Design and orchestrator skill are out of sync (§7 gates missing in `SKILL.md`, §14 drift)
- `implementer` preflight failed or user says "the implementer should have caught X"
- User wants to harden templates/checklists for **all future** harnesses (meta)
- After running an orchestrator, runtime behavior does not match `HARNESS_DESIGN.md` (instance, sometimes meta)

Do **not** use for:

- Brand-new harness from scratch → `designer`
- First orchestrator scaffold with no prior design → `implementer`
- Editing delegate skills (`jet-smoke-to-playwright`, etc.) unless user explicitly requests
- Generic skill authoring unrelated to harnesses → `skill-creator`

## Operating modes

| Mode | Layer | When |
|------|-------|------|
| `meta-only` | Designer / implementer skills only | Process/template/checklist fix |
| `instance-only` | One `<orchestrator>` | This harness is wrong; pipeline skills are fine |
| `full-loop` | Meta then instance | Pattern will repeat; fix pipeline + current harness |

State the chosen mode in the EnhancementBrief before editing files.

## Workflow

### 1. Intake (multi-message safe)

Gather from the current conversation and explicit paths:

- **Orchestrator name** (kebab-case), if any
- **`HARNESS_DESIGN_PATH`** if user set it; else `harness-designs/<orchestrator>/HARNESS_DESIGN.md`
- **Feedback messages** — treat the full thread as source material
- **Trigger** — `user` | `system` (preflight failure, drift detected, runtime mismatch)

If the user is still adding constraints ("also…", "and…") without asking to apply yet, **do not edit** — acknowledge and wait, or ask: "Ready to apply all feedback as one batch?"

When the user signals apply ("go", "implement", "fix it", "listo"), proceed to step 2.

### 2. Write EnhancementBrief

Use `assets/ENHANCEMENT_BRIEF.template.md`. Fill every field; set **mode** (`meta-only` | `instance-only` | `full-loop`).

Optional persistence (recommended for large changes):

```text
harness-designs/<orchestrator>/ENHANCEMENT.md
```

For **meta-only**, write brief to chat only unless user wants it under `harness-designs/_meta/ENHANCEMENT-<date>.md`.

**Stop for user confirmation** when:

- Changes touch more than 3 files, or
- Deleting/renaming an orchestrator, or
- User has not yet said to apply

Otherwise proceed if feedback is small and unambiguous.

### 3. Classify layer

Follow `references/classification.md`. Document decision in the brief.

### 4. Apply patches

| Layer | Guide |
|-------|--------|
| Meta | `references/meta-patch-guide.md` |
| Instance | `references/instance-patch-guide.md` |

**Sync rule (instance):** when §3, §7, §13, or §14 change, update those sections **together** in `harness-designs/<orchestrator>/HARNESS_DESIGN.md`. See `../designer/references/design-implementer-handoff.md`.

**Stale-report rule (instance):** the same behavioral change invalidates any prior `harness-designs/<orchestrator>/VALIDATION_REPORT.md` — set its `Status: stale` (note which § changed). A stale report is not a valid production precondition; the orchestrator must be re-validated. See `references/rerun-matrix.md`.

**Version bump:** increment `> Version N` or `Designed: YYYY-MM-DD` in the design header after instance edits.

**Do not** modify delegate skill bodies unless the user explicitly requests.

### 5. Re-run matrix

Use `references/rerun-matrix.md`. Defaults:

| After… | Re-run |
|--------|--------|
| Meta checklist/template only | None (unless user wants instance regression) |
| Instance §7 / §13 / §14 | `implementer` with sync, **then mark report `stale` + hand back to `validator`** |
| Full architecture (§1–§12) | `designer` (targeted) then `implementer` then `validator` |
| Orchestrator typo in `SKILL.md` only | None |

Any behavioral instance change (§3/§7/§13/§14) closes the loop only when the orchestrator is **re-validated** — the enhancer marks the old report `stale` and hands back to `validator` (it does not run the validator itself).

**Session limits:** at most **one** designer re-run, **one** implementer re-run, and **one** validator hand-back per enhancer session unless the user asks for another round. The validator↔enhancer cycle is bounded — after **2** `failed` rounds the validator escalates to the operator instead of re-signalling.

#### Re-run designer (targeted)

Load `skills/designer/SKILL.md`. Re-run **only** the phases needed (e.g. §7–§14 refresh, or §1–§12 if architecture changed). Do not recreate unrelated harnesses.

#### Re-run implementer (sync)

```text
Load implementer with:
  HARNESS_DESIGN_PATH=harness-designs/<orchestrator>/HARNESS_DESIGN.md
  UPDATE_IN_PLACE=true
```

`UPDATE_IN_PLACE=true` makes the implementer update an existing orchestrator without prompting (implementer step 1.7), so the automated enhancer → implementer repair loop does not stall on a confirmation question.

### 6. Validate and report

- Designer/implementer handoff checklist if instance changed: `../designer/references/design-implementer-handoff.md`
- If orchestrator touched: `python3 skills/skill-creator/scripts/package_skill.py skills/<orchestrator> skills/skill-creator/dist`
- Summarize: mode, files changed, meta vs instance, re-runs performed, optional "extract lesson to meta?" if instance-only fix might generalize

## System triggers (suggested handling)

Many of these arrive pre-classified from a **`validator` failure** — its `VALIDATION_REPORT.md` "Failure signal" block already carries `Trigger: system`, a root cause, suggested mode, and target files. Treat that block as ready intake for step 2.

The root-cause vocabulary (`failed handoff | drift | runtime mismatch`) is defined canonically in `../validator/references/enhancer-handoff.md`; the rows below map each to a default action. After patching, the loop closes by handing back to `validator` (see `references/rerun-matrix.md`).

**Prompt-caused runtime mismatch (optional diagnostic).** When the root cause is `runtime mismatch` but the design and orchestrator skill are in sync — the orchestrator *behaves* wrong despite a correct design — the failure is likely in the prompt itself. Classify it via `../prompt-engineering/references/failure-taxonomy.md` (18 prompt-failure categories with risk scores) and consult the matching `mistakes-*.md` (`mistakes-hallucinations.md` / `mistakes-structure.md` / `mistakes-context.md` / `mistakes-debt.md` / `mistakes-security.md`) for the fix pattern before patching §13. Record the taxonomy category in the EnhancementBrief so the diagnostic is accountable.

| Signal | Likely layer | Default action |
|--------|--------------|----------------|
| `validator` report `failed` (gate/§8/preflight) | Instance (meta if pattern) | Use the report's suggested mode; patch the named target files; sync implementer |
| §13 missing on implement | Instance or meta | Instance: run designer §13; Meta: strengthen implementer preflight message |
| §14 invalid / missing | Instance | Fix design §14 or derive per `mermaid-diagrams.md`, then implementer |
| §6 delegate missing in §14 bundle | Instance | Patch §14 + `skill-delegation.md` via implementer |
| Same preflight failure on 2+ harnesses | Meta | Patch implementer/designer checklist |
| Runtime orchestrator skipped a gate | Instance | Patch §7 + §3; sync implementer |

## Relationship to other skills

| Skill | Role |
|-------|------|
| `enhancer` | This skill — feedback → brief → patch → optional re-run |
| `validator` | Upstream signal source (failure block = `system` intake) **and** downstream re-validation target after a behavioral patch |
| `designer` | Greenfield / major redesign; delegated partial re-run |
| `implementer` | Build/sync orchestrator; delegated after instance patch |
| `skill-creator` | Used only inside implementer (not by enhancer directly) |
| `<orchestrator>` | Runtime; enhancer does not execute migration/review workflows |

## Resources

| Path | Purpose |
|------|---------|
| `references/classification.md` | Meta vs instance vs both |
| `references/enhancement-brief.md` | Brief field definitions |
| `references/meta-patch-guide.md` | Editing designer/implementer |
| `references/instance-patch-guide.md` | Feedback → design §§ |
| `references/rerun-matrix.md` | When to re-run sibling skills |
| `../prompt-engineering/references/failure-taxonomy.md` | Classify prompt-caused runtime mismatch → matching `mistakes-*.md` fix patterns |
| `assets/ENHANCEMENT_BRIEF.template.md` | Brief skeleton |
