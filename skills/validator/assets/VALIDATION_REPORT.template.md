# VALIDATION_REPORT — {ORCHESTRATOR_NAME}

> Validated: {YYYY-MM-DD}
> Orchestrator: {orchestrator-name}
> Design: harness-designs/{orchestrator-name}/HARNESS_DESIGN.md
> Design version validated: {§ header Version N / Designed date} @ {git short SHA of design at validation time}
> Round: {N} (validator↔enhancer cycle; escalate to operator after 2 failed rounds)
> Status: validated | failed | stale
> Scope: {ONE item — unit smoke | TWO items — batch-boundary smoke for migration/batch-processing}. Full-batch behavior (loop / dedup / termination at scale) NOT exercised.

<!-- Status=stale: the design changed since this report (enhancer edited §3/§7/§13/§14).
     The orchestrator must be re-validated; do not trust a stale report as a prod precondition. -->

## Item(s) under test

- Worklist item 1: {id / path} — {canonical / smallest representative}
- Worklist item 2 (migration/batch domains only): {id / path} — {dedup-skip case / next item} or `n-a`
- Selector from §3: {tag/header/dir/manifest}
- Batch-boundary result (two-item runs): advanced past item 1 / dedup-skip applied / terminated cleanly — {pass / fail / n-a}

## Preflight (light, fail-fast)

- [ ] Orchestrator files present (`SKILL.md`, `assets/workflow.mermaid.md`, `references/`)
- [ ] §7 gates runnable-shaped (command + where-to-run + filter syntax)
- [ ] §6 delegates resolve at orchestrator home (readable `SKILL.md`; venv interpreter present if applicable)
- Environment dependencies (external delegates resolved outside this repo): {list paths, or "none"} — harness runs only where these are cloned/installed

## Smoke-run

- Worktree: {path} (discarded after run)
- Orchestrator executed on item: yes / no
- Mode: behavioral / rules-only (no run)

## Gate results (§7)

| Gate | Command | Result |
|------|---------|--------|
| run | {cmd} | pass / fail |
| flake | {cmd} | pass / fail |
| scope-lock | `git status --porcelain` … | pass / fail |
| fidelity-parity (migration only) | {cmd / manual} | pass / fail / n-a |

## Human sign-off (§8)

- [ ] Operator: gates passed + output looks correct
- Notes: {fidelity / brand / UX observations}

---

## Failure signal (only if Status = failed) — input for enhancer

> Drop-in compatible with `enhancer` ENHANCEMENT_BRIEF intake.

- Trigger: system
- Root cause: failed handoff | drift | runtime mismatch
- Symptom: {which §7 gate failed / which §8 check declined / preflight gap}
- Suggested mode: instance-only | meta-only | full-loop
- Target files: {paths}

Handoff: `Load enhancer with the failure signal above (Trigger: system).`
