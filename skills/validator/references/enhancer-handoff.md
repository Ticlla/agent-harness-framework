# Failure handoff to enhancer

When validation fails, the validator does **not** fix anything. It emits a signal the `enhancer` consumes as a `system` trigger, then tells the user to load the enhancer.

> **Canonical failure-cause enum.** The validator failure signal's root cause is exactly one of `failed handoff | drift | runtime mismatch`. This file is the single source for that vocabulary — the `VALIDATION_REPORT.md` failure block and the enhancer's System-triggers table both reference it. Do not introduce a fourth value without updating all three. (This is distinct from the enhancer's broader ENHANCEMENT_BRIEF "Root cause" hypothesis field `meta gap | instance drift | runtime mismatch | unclear spec` — the 3-value signal feeds *into* that classification.)
>
> **Canonical modes.** Suggested mode is exactly one of `instance-only | meta-only | full-loop` — defined by `enhancer` SKILL "Operating modes". Use `meta-only` (never bare `meta`).

> **Bounded loop.** Stamp `Round N` on the report. After **2** rounds still ending `failed`, do not re-signal — escalate to the operator with a per-round summary (likely a meta gap or a design decision a human must make).

## Map the failure → enhancer vocabulary

The enhancer's System-triggers table (`../../enhancer/SKILL.md`) recognizes these. Match the validation failure to one:

| Validation failure | Root cause | Likely layer | Suggested mode |
|--------------------|-----------|--------------|----------------|
| Preflight: §13/§14 missing or unparseable | failed handoff | instance (or meta) | instance-only |
| Preflight: §6 delegate missing at home | failed handoff | instance | instance-only |
| Preflight: §7 gate not runnable-shaped | drift | instance | instance-only |
| Smoke-run: orchestrator skipped a gate it should run | runtime mismatch | instance | instance-only |
| §7 gate executed but failed (run/flake/scope) | runtime mismatch | instance | instance-only |
| §8 sign-off declined (fidelity/brand/UX) | runtime mismatch | instance | instance-only |
| **Same failure pattern seen on 2+ harnesses** | drift / runtime mismatch (recurring) | meta | full-loop |

Recurrence across harnesses is expressed by **Layer = meta** + **mode = full-loop**, not by a new root-cause value — the root cause stays one of the three canonical values (the *same* `drift` / `runtime mismatch` that keeps recurring). "meta gap" is a layer/lesson description, never a root-cause enum value.

If a failure would recur on *any* harness built the same way (not specific to this one), suggest **meta-only** or **full-loop** so the enhancer hardens the designer/implementer, not just this instance.

## Fill the report's failure-signal block

In `VALIDATION_REPORT.md`:

- Trigger: `system`
- Root cause: one of `failed handoff | drift | runtime mismatch`
- Symptom: which gate / which §8 check / which preflight item
- Suggested mode: `instance-only | meta-only | full-loop` (must match the enhancer's modes exactly)
- Target files: concrete paths (design §§, `skills/<orchestrator>/SKILL.md`, etc.)

## Handoff message to the user

```text
Validation FAILED for <orchestrator>. Report: harness-designs/<orchestrator>/VALIDATION_REPORT.md

Next: load enhancer. The report's "Failure signal" block is a ready system trigger
(Trigger: system, root cause + suggested mode filled in). The enhancer will classify
meta vs instance, write an EnhancementBrief, patch, and re-run designer/implementer as needed.
```

The enhancer drives the re-run (per its `rerun-matrix.md`); the validator never invokes designer/implementer itself.
