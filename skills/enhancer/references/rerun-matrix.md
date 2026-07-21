# Re-run matrix

After enhancer patches, delegate to sibling skills — do not reimplement their workflows inside enhancer.

## Matrix

| Change made | designer | implementer | Notes |
|-------------|------------------|---------------------|-------|
| Meta handoff/checklist only | No | No | Optional: sync one harness to validate |
| Meta parse/orchestrator checklist | No | No* | *User may ask to sync all harnesses — out of default scope |
| Instance typo in orchestrator `SKILL.md` only | No | No | Direct edit OK |
| Instance §7 gates | No** | **Yes** | **Designer only if §14 gates diagram must change |
| Instance §6 delegates | Rare | **Yes** | Designer if §14 bundle outdated |
| Instance §3 behaviors | Maybe §3–§14 | **Yes** | Designer if batch flow rewrite is large |
| Instance §13 workflow graph | **Yes** (§13–§14) | **Yes** | Keep §14 aligned |
| Instance §1–§12 architecture | **Yes** | **Yes** | Full targeted designer pass |
| New orchestrator (missing skill dir) | **Yes** if design incomplete | **Yes** | If no design at all, use designer not enhancer |
| `rules-only` harness | **Yes** if §13 mode change | No orchestrator | See implementer `rules-only.md` |

## Environment for implementer re-run

```text
HARNESS_DESIGN_PATH=harness-designs/<orchestrator>/HARNESS_DESIGN.md
UPDATE_IN_PLACE=true
```

Implementer step 1.7: with `UPDATE_IN_PLACE=true` it **updates in place without prompting** when `skills/<orchestrator>/` exists — keeps the repair loop unattended.

## Environment for designer re-run

Specify to designer:

- Orchestrator name (existing)
- **Scope:** e.g. "Refresh §7, §13, §14 only from feedback; do not change §1 objective"
- Path: `harness-designs/<orchestrator>/HARNESS_DESIGN.md`

Designer must not create a second harness folder.

## Re-validate after a behavioral change

A prior `VALIDATION_REPORT.md` is **only valid for the design version it ran against**. When an instance edit changes behavior, the report goes stale — do not let a stale `validated` badge stand.

| Change made | VALIDATION_REPORT action | Re-run validator |
|-------------|--------------------------|------------------|
| Instance §3 / §7 / §13 / §14 (behavior) | Set existing report `Status: stale` (note which § changed) | **Yes** — after implementer sync, hand back to `validator` |
| Instance typo in `SKILL.md` only | Leave as-is | No |
| Meta checklist/template only | Leave instance reports as-is | No (unless user wants a regression validate) |
| `rules-only` design change | Set report `stale` | Yes — rules-only artifact review |

After the implementer sync completes, tell the user:

```text
Load validator with:
  HARNESS_DESIGN_PATH=harness-designs/<orchestrator>/HARNESS_DESIGN.md
```

The enhancer marks the report stale; it does **not** run the validator itself (same delegation rule as designer/implementer).

## Session limits

Per enhancer session:

- Max **1** `designer` delegation
- Max **1** `implementer` delegation
- Max **1** `validator` hand-back

Additional rounds require explicit user request. The validator↔enhancer cycle is bounded: after **2** rounds still ending `failed`, the validator escalates to the operator instead of re-signalling — do not start a third automatic round.

## Validation after re-run

1. `design-implementer-handoff.md` checklist
2. `package_skill.py skills/<orchestrator> skills/skill-creator/dist` if orchestrator exists
3. Report zip path and trigger phrase from §13
4. If behavior changed: mark the old `VALIDATION_REPORT.md` `stale` and hand back to `validator`
