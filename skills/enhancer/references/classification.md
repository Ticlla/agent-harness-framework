# Meta vs instance classification

## Definitions

**Meta** — Skills and references that define **how every harness is designed and built**:

- `skills/designer/` (templates, primitives/profiles, §14 rules)
- `skills/implementer/` (parse §13/§14, scaffold, package)
- Shared handoff docs under `designer/references/` (e.g. `design-implementer-handoff.md`)

**Instance** — **One** named orchestrator and its design:

- `harness-designs/<orchestrator>/HARNESS_DESIGN.md`
- `skills/<orchestrator>/` (SKILL.md, references, assets)
- Optional: `harness-designs/<orchestrator>/ENHANCEMENT.md`, `FEEDBACK.log`

`<orchestrator>` is kebab-case and matches the folder name (e.g. `jet-p0-migration-harness`).

## Decision tree

```
Feedback about "the pipeline" or "always" or "every harness"?
  YES → meta (or full-loop if a specific harness is also broken)
  NO  → continue

Feedback names a specific orchestrator or HARNESS_DESIGN_PATH?
  YES → instance (or full-loop if designer/implementer caused it)
  NO  → ask user which orchestrator, or treat as meta if about templates only
```

## Examples

| User says | Layer |
|-----------|--------|
| "§7 must always include shell commands in every design" | Meta |
| "jet-p0 is missing flake gate in SKILL.md" | Instance |
| "Implementer never copies §7 — fix that and update jet-p0" | full-loop |
| "Runbook has @ada but send skill also tags — double mention" | full-loop (§6 input contract + delegate fix) |
| "Harness study reports are text-only — need mermaid diagrams" | full-loop (§3 diagram contract + Gate 6 + report refresh) |
| "Add HITL before PR in JET migration harness" | Instance |
| "Handoff checklist should require two mermaid blocks" | Meta |
| "Designer should add a primitive-selection step for §1–§12" | Meta |

## Both layers (full-loop)

Use **full-loop** when:

1. Instance is wrong **because** meta allowed or caused it (missing checklist, weak parse rule), and
2. Fixing only the instance would leave the next harness broken the same way.

Order: **meta first** (small, targeted patch), then **instance** (design §§), then **implementer sync**.

## Out of scope for enhancer

| Topic | Use instead |
|-------|-------------|
| New harness from zero | `designer` |
| Convert one JET test | `jet-smoke-to-playwright` / `jet-to-playwright` |
| Worktree setup | `fusion-worktree` |
| Run migration batch | `<orchestrator>` |
