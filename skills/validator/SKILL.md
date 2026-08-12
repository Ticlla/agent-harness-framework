---
name: validator
description: Proves a built or resynced harness before production trust. Smoke-runs one real §3 worklist item in a throwaway git worktree (or static review for rules-only), executes §7 gates, records human sign-off in VALIDATION_REPORT.md. On failure, emits enhancer signal. Not for design, build, or full batch runtime.
---

# Harness validator

Third stage of the harness framework. The designer/implementer/enhancer verify a harness **at the document level** (checklists, static design↔skill drift). Nothing runs the orchestrator against real work before it ships. This skill closes that gap: it **smoke-runs the built orchestrator on one real item in an isolated worktree**, executes its §7 gates, and requires a human sign-off — turning latent production failures into a signal **before** ship.

Pipeline: `designer` → `implementer` → **`validator`** → run → (`enhancer` on fail).

This is a **meta skill** (operates on any harness). It does not get its own `HARNESS_DESIGN.md`.

## Scope — and what it does NOT prove

- **Unit smoke, not batch.** Validation runs the orchestrator on **one** item (or **two** for `migration`/`batch-processing` domains — see step 3). It proves the happy path runs end-to-end and the §7 gates execute. A one-item run does **not** exercise batch behavior (worklist loop, cross-item dedup, exhaustion/termination, cross-item state); the two-item run exercises that boundary **once** but is still not a full batch. Full-batch behavior remains unproven until a real run.
- **Advisory gate, not enforced.** A `validated` report is the expected precondition for a production batch, but nothing hard-blocks running an unvalidated orchestrator. The convention is: do not trust a harness on a real batch without a current `validated` report.

## Input contract (from implementer)

| Input | Required | Default |
|-------|----------|---------|
| Orchestrator name | Yes | — |
| `HARNESS_DESIGN_PATH` | Yes | `harness-designs/<orchestrator>/HARNESS_DESIGN.md` |
| Orchestrator home | If §13 mode = orchestrator skill | `skills/` in this repo; may be external (`../<repo>/skills/`, `~/.claude\|.cursor/skills`) per §13 |
| Built orchestrator at `<home>/<orchestrator>/` | **Only if** §13 mode = orchestrator skill | resolved from home above |
| Generated rules/artifacts in target repo | **Only if** §13 mode = rules-only | path from design (`AGENTS.md` / `.cursor/rules/*`) |
| Real target repo (§2) | For behavioral run (orchestrator mode) | from design §2 (must be a git repo) |

The **canonical design file** (`HARNESS_DESIGN_PATH`) is always required. The built orchestrator is required **only** for orchestrator-skill mode; `rules-only` harnesses have no orchestrator skill and validate the generated artifacts instead (see step 1 + `references/preflight-checklist.md`).

## When to use

- An orchestrator was just built by `implementer` and you want proof it actually runs
- Before trusting a harness on a real batch / in production
- After an enhancer sync, to re-confirm the orchestrator still runs

Do **not** use for: writing the design (`designer`), building the orchestrator (`implementer`), feedback-driven patching/drift repair (`enhancer`), or doing real runtime work (the orchestrator itself — validation runs ONE item, throwaway).

## Prerequisites

- Design readable at `HARNESS_DESIGN_PATH` (always required)
- **Orchestrator-skill mode:** built orchestrator at `<home>/<orchestrator>/` (SKILL.md, `assets/workflow.mermaid.md`, `references/`) — `<home>` is the §13 orchestrator home (default `skills/`, may be external); and for a behavioral run the §2 target repo exists locally and is a git repo
- **rules-only mode:** generated rules/artifacts present at the design's target path — no orchestrator skill, no behavioral run (see step 1)

## Workflow

### 1. Load & resolve

Read the design at `HARNESS_DESIGN_PATH` (default `harness-designs/<orchestrator>/HARNESS_DESIGN.md`). Parse §13 and resolve **Implementation mode** first — do not read an orchestrator `SKILL.md` until mode is known.

If **rules-only** → no orchestrator skill exists. Run the **rules-only branch** in `references/preflight-checklist.md` (review generated artifacts + human sign-off on those artifacts), then jump to step 7. Skip steps 2–6 and 9 (no smoke-run, no worktree).

If **orchestrator-skill** → resolve the **orchestrator home** from §13 (default `skills/`; may be `../<repo>/skills/` or an install dir). Read `<home>/<orchestrator>/SKILL.md` and its `references/HARNESS_DESIGN.md` (or compare against `HARNESS_DESIGN_PATH`). Continue to step 2.

### 2. Light preflight (fail-fast, orchestrator-skill only)

Run the orchestrator-skill checks in `references/preflight-checklist.md`: files present; §7 gates **runnable-shaped** (command + where-to-run + filter syntax); §6 delegates resolve at the orchestrator home. This is a sanity gate — **not** the enhancer's full drift matrix (`../enhancer/references/instance-patch-guide.md` owns deep drift).

**If preflight fails → skip the smoke-run, jump to step 7 with `failed`. Never run a broken skill.**

**Optional prompt-quality audit (advisory, never gating).** For a deeper read of the orchestrator's `SKILL.md` prompt — useful when the smoke-run is clean but you want to flag latent prompt risks, or in `rules-only` mode where there is no behavioral run — work through `../prompt-engineering/references/prompt-audit-checklist.md` and record notable Critical/Warning items under a `Prompt audit` section in the report. Record `Prompt audit: n/a` if you skip it, so the report shows the check was considered. This never changes `validated`/`failed` on its own.

### 3. Pick worklist item(s)

Per `references/pick-worklist-item.md`: from the deterministic §3 selector, pick the smallest/canonical representative. For `migration`/`batch-processing` domains (§1), pick a **second** item too, to exercise the loop/dedup/termination boundary once (two-item smoke). Record the item(s) + why in the report. If the selector is ambiguous, ask the operator.

### 4. Smoke-run in an isolated worktree

Per `references/smoke-run-worktree.md`: create a throwaway worktree of the §2 target repo using the isolation mechanism the design specifies (a plain `git worktree add` by default; a domain worktree skill only if §2/§13 names one). Run the orchestrator on the picked item(s) **inside the worktree** (one pass across both for the two-item batch smoke). **Never push, never open a PR, never commit to a shared branch.**

### 5. Execute §7 gates

Run the design's §7 gates **in the worktree**; record pass/fail per gate (run, flake, scope-lock, fidelity-parity for migration harnesses). Honor §7 `where-to-run`/env/baseURL/filter gotchas.

### 6. Human sign-off (§8)

Present the local `git diff` (in the worktree) + gate results to the operator. The operator signs off in the report. §8 judgment checkpoints (fidelity, brand, UX) surface here — auto-gates cannot judge them.

### 7. Emit VALIDATION_REPORT.md

Write `harness-designs/<orchestrator>/VALIDATION_REPORT.md` from `assets/VALIDATION_REPORT.template.md` + chat summary. Status `validated` **only if** every §7 gate passed **and** the operator signed off; otherwise `failed`.

### 8. On `failed` → hand off to enhancer

Per `references/enhancer-handoff.md`: fill the report's failure-signal block (`Trigger: system`, root cause `failed handoff | drift | runtime mismatch`, suggested mode, target files) and tell the user to load `enhancer`. The validator does **not** fix anything itself.

**Loop escape.** Record the validation round (`Round N`) in the report. The validator↔enhancer cycle is bounded: after **2** rounds that still end `failed`, stop emitting a fresh signal — **escalate to the operator** with a short summary of what failed each round, rather than looping again. A persistent failure across rounds usually means a meta gap (suggest `meta-only`/`full-loop`) or a design assumption that needs a human decision.

### 9. Discard the worktree

Always — pass or fail. Leave the target repo working tree clean; nothing pushed.

## Fail-closed rules

- Never push / open PR / commit to a shared branch during validation.
- Never mark `validated` if any §7 gate fails or the operator declines sign-off.
- Never smoke-run when preflight fails — emit a signal instead.
- Worktree is always discarded.
- `rules-only` harness → no smoke-run; review generated artifacts + sign-off only (see `references/preflight-checklist.md` for the exact rules-only checks).
- Read-only on the design and orchestrator skill — fixes are the enhancer's job.
- **Minimal smoke scope** — default **one** worklist item; **two** for `migration`/`batch-processing` domains (step 3). A `validated` report covers that smoke path only, **not** full batch behavior (loop/dedup/termination across the whole worklist). Pin the design version validated (report header) so the badge can be detected as stale after an enhancer edit.
- Bounded loop — escalate to the operator after 2 `failed` rounds instead of re-signalling the enhancer again.

## Relationship to other skills

| Skill | Role |
|-------|------|
| `designer` | Upstream — defines §3 worklist, §7 gates, §8 checkpoints validated here |
| `implementer` | Upstream — builds the orchestrator under test |
| `validator` | This skill — behavioral smoke-run + human sign-off → VALIDATION_REPORT |
| `enhancer` | Downstream on `failed` — consumes the failure signal |
| worktree skill (optional) | Isolation for the smoke-run **only if** §2/§13 names one (e.g. `fusion-worktree` for Nuxt); else plain `git worktree` |
| `<orchestrator>` | The thing under test (validator runs it once, in isolation) |

## Resources

| Path | Purpose |
|------|---------|
| `references/preflight-checklist.md` | Light fail-fast sanity + rules-only branch |
| `references/pick-worklist-item.md` | Choose one representative §3 item |
| `references/smoke-run-worktree.md` | Isolated worktree run + teardown |
| `references/enhancer-handoff.md` | Map failures → enhancer signal vocabulary |
| `../prompt-engineering/references/prompt-audit-checklist.md` | Optional advisory 8-dimension prompt audit of the orchestrator `SKILL.md` |
| `assets/VALIDATION_REPORT.template.md` | Report skeleton (failure block = enhancer-compatible) |
