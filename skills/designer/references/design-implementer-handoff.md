# Design → implementer handoff (§13 + §14)

`designer` and `implementer` are **one pipeline**. The design is incomplete without §14; the implementer cannot ship without both sections.

## Designer deliverables (blocking)

| Section | Content | Implementer uses it for |
|---------|---------|-------------------------|
| §1–§12 | Architecture, gates, delegates | `references/harness-spec.md`, `skill-delegation.md` |
| §13 | Orchestrator name, workflow summary, assets list, AGENTS line | `init_skill.py`, SKILL.md body, templates |
| §14 | Mermaid: skill bundle + batch flow (+ optional gates) | `assets/workflow.mermaid.md`, `## Workflow diagrams` in SKILL.md |

**Output file:** `harness-designs/<orchestrator>/HARNESS_DESIGN.md` (folder name = §13 orchestrator name).

## Validation before handoff

Designer confirms:

- [ ] §13 `Implementation mode` is set
- [ ] §13 orchestrator name is kebab-case and matches folder under `harness-designs/`
- [ ] §13 `Orchestrator home` is set (this repo `skills/` or an external repo/dir); §6 records each delegate's location and they are available (installed or co-located) at that home
- [ ] Row added/updated in `harness-designs/README.md` (create the file from the Catalog template in `harness-design-layout.md` if it does not exist yet)
- [ ] §14 has at least two `mermaid` fenced blocks (bundle + batch flow)
- [ ] §14 batch flow matches §3 behaviors and §13 ASCII graph (if present)
- [ ] §6 delegate table matches §14 skill-bundle nodes
- [ ] **Delegate input contract:** for any §6 delegate that **transforms** orchestrator inputs (prepend mention/tag, strip prefix, rewrite paths/URLs, wrap payload), document the contract in §6 (`Input contract` column or bullet per row). §3 must state orchestrator passes runbook/source text **unchanged** unless the design explicitly assigns normalization to the orchestrator (never both orchestrator and delegate).
- [ ] §7 gate commands are copy-paste-ready (one defined placeholder convention; no concrete/placeholder mix for the same arg)
- [ ] §7 scope checks catch untracked files (`git status --porcelain`, not `git diff --name-only`)
- [ ] (harness operates on real repos) §2 names real source/target repo paths; §7 run command + scope-lock path verified against the actual target repo (not invented)
- [ ] (batch/migration harness) §3 worklist/selection source is deterministic (tag/header/dir/manifest/suite), not "ask the user"
- [ ] (batch/migration harness) worklist selector verified for completeness across the full tree (not anchored to one suite/dir; count recorded); any ambiguous/unlabeled criterion flagged for human confirmation
- [ ] (batch/migration harness) §12 `PLAN.md` defines a per-item **status table** (status enum + progress) for visual validation
- [ ] (migration/porting harness) §7/§8 include a **fidelity-parity gate** (source assertion/behavior represented or waived) and a **source→target data/dependency mapping** step that escalates on no equivalent (never fabricates), both at orchestrator level (delegate authors output)
- [ ] (executable-artifact harness — deliverable is a codemod/transform/generator/script) §7 includes an **executed** "runs green on its own fixtures" gate; declared dependency pins resolve to published releases; **presence-only definition of done is rejected** (see `domain-profiles.md` → Executable-artifact gate)

## Handoff message (copy to user)

```text
Design ready at harness-designs/<orchestrator>/HARNESS_DESIGN.md (§13 + §14).

Next: load implementer with:
  HARNESS_DESIGN_PATH=harness-designs/<orchestrator>/HARNESS_DESIGN.md

The implementer will scaffold skills/<orchestrator>/ including references/HARNESS_DESIGN.md and workflow.mermaid.md.

After implement: run validator (smoke-run on one §3 item + §7 gates + sign-off)
before trusting the harness in production.
```

## Implementer preflight

Implementer **rejects or pauses** if:

- §13 missing → ask to run `designer`
- `HARNESS_DESIGN_PATH` points at repo-root `HARNESS_DESIGN.md` (pointer only) → use `harness-designs/<name>/HARNESS_DESIGN.md`
- §14 missing → derive Mermaid per `mermaid-diagrams.md`, then **append §14 to the source design file** under `harness-designs/`
- §14 present but invalid → fix syntax, sync with §13, update design file §14

## Sync rule after changes

When workflow changes in production:

1. Edit `harness-designs/<orchestrator>/HARNESS_DESIGN.md` §3, §13, §14 together
2. Re-run `implementer` to sync `skills/<orchestrator>/` (SKILL.md, `references/HARNESS_DESIGN.md`, `assets/workflow.mermaid.md`)

For feedback-driven or multi-message fixes, use **`enhancer`** (classify meta vs instance, EnhancementBrief, then optional designer/implementer re-run per `skills/enhancer/references/rerun-matrix.md`).
