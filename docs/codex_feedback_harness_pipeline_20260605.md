# Codex Feedback: Harness Pipeline Implementation

> **HISTORICAL — 2026-06-05. All four findings below have since been RESOLVED.** This document is kept as a review record, not a current assessment. The closing "should not be merged as-is" verdict (§ Overall Assessment) reflects the state *at review time* and no longer holds.
>
> Resolution status:
> - **Finding 1 (catalog README missing)** — RESOLVED: `harness-designs/README.md` ships as an empty catalog; all skills say "create from template if missing".
> - **Finding 2 (mode/root-cause vocab)** — RESOLVED: canonical enum `instance-only | meta-only | full-loop` and root cause `failed handoff | drift | runtime mismatch`, single-sourced in `skills/validator/references/enhancer-handoff.md`; `meta gap` is a layer/lesson, not an enum value.
> - **Finding 3 (rules-only input contract)** — RESOLVED: built orchestrator required only when §13 mode = orchestrator skill; rules-only validates generated artifacts.
> - **Finding 4 (update-in-place vs enhancer)** — RESOLVED: `UPDATE_IN_PLACE=true` handoff makes the implementer update in place without prompting.

## Summary

The implementation introduces a strong harness pipeline:

`designer` -> `implementer` -> `validator` -> runtime -> `enhancer` on failure.

The architecture is directionally solid. The new validator stage closes an important gap between "the design looks coherent" and "the orchestrator actually runs." The main issues are cross-skill contract inconsistencies that can break the first real end-to-end run.

## Findings

### 1. Blocking: `harness-designs/README.md` is required but not present

Several workflows require checking or updating this catalog, but the branch does not include `harness-designs/README.md`. That means the first real `designer` / `implementer` run will either fail, invent the file shape, or silently diverge.

References:

- `skills/designer/SKILL.md`
- `skills/designer/references/harness-design-layout.md`
- `skills/designer/references/design-implementer-handoff.md`
- `skills/implementer/SKILL.md`

Recommended fix:

Add an empty catalog with the expected columns, or change all instructions to say "create if missing" and provide the exact template.

### 2. Blocking: validator -> enhancer signal vocabulary is inconsistent

`enhancer` defines modes as:

`meta-only | instance-only | full-loop`

But the validator report/handoff uses:

`instance-only | meta | full-loop`

Also, `enhancer-handoff.md` says root cause is exactly:

`failed handoff | drift | runtime mismatch`

Then it uses `meta gap` as a root cause in the mapping table.

References:

- `skills/enhancer/SKILL.md`
- `skills/validator/assets/VALIDATION_REPORT.template.md`
- `skills/validator/references/enhancer-handoff.md`

Recommended fix:

Use `meta-only` everywhere for mode. Keep `meta gap` as a hypothesis or lesson, not a root-cause enum value, unless the enum is expanded consistently in all validator/enhancer references.

### 3. High: rules-only validation contradicts the validator input contract

The validator says a built orchestrator at `<home>/<orchestrator>/` is required, but rules-only mode explicitly has no orchestrator skill. The workflow later supports rules-only, but the prereq/input contract can cause an agent to fail before reaching that branch.

References:

- `skills/validator/SKILL.md`
- `skills/validator/references/preflight-checklist.md`
- `skills/implementer/references/rules-only.md`

Recommended fix:

Mark the built orchestrator as required only when `Implementation mode = orchestrator skill`. For `rules-only`, validation should require generated artifacts plus the canonical design file.

### 4. Medium: implementer update behavior conflicts with enhancer re-run behavior

`enhancer` says the implementer runs "update in place" for existing orchestrators, but `implementer` step 1.7 says to ask "update in place or abort." That can stall an automated validator -> enhancer -> implementer repair loop.

References:

- `skills/implementer/SKILL.md`
- `skills/enhancer/SKILL.md`
- `skills/enhancer/references/rerun-matrix.md`

Recommended fix:

Make update-in-place the default when invoked from enhancer, or require an explicit `UPDATE_IN_PLACE=true` handoff.

## Overall Assessment

The pipeline decomposition is good, especially the addition of `validator` as a behavioral smoke stage. The implementation should not be merged as-is until the cross-skill contracts are made internally consistent.

`quick_validate.py` passes for the four skills, but that only validates skill structure, not end-to-end workflow correctness.
