# Instance patch guide (one orchestrator)

Target harness: `harness-designs/<orchestrator>/HARNESS_DESIGN.md` and optionally `skills/<orchestrator>/`.

## Resolve paths

1. Orchestrator name from user or `HARNESS_DESIGN_PATH`.
2. Design: `harness-designs/<orchestrator>/HARNESS_DESIGN.md` (canonical — edit here first).
3. Runtime: `skills/<orchestrator>/` if it exists.
4. Catalog row: `harness-designs/README.md` (create from the template in `../designer/references/harness-design-layout.md` if missing).

Never edit repo-root `HARNESS_DESIGN.md` except the pointer file — it is not a harness design.

## Feedback → design sections

| User intent | Edit sections | Also update |
|-------------|---------------|-------------|
| Verification / CI commands | §7, §14 (gates diagram) | orchestrator `SKILL.md` via implementer |
| Who loads which skill | §6, §13, §14 (bundle) | `references/skill-delegation.md` via implementer |
| Delegate transforms runbook input (send mention, strip, rewrite) | §3 (pass-through rule), §6 (input contract column) | send/transform delegate docs; fail-closed in orchestrator SKILL |
| Report set lacks diagrams / Gate 6 fails | §3 (diagram contract), §7 Gate 6, report templates | `harness-study/reports/<slug>/` add mermaid; `check_grounding.py --diagrams` |
| Agent loop / batch steps | §3, §13 graph, §14 (batch flow) | `assets/workflow.mermaid.md` via implementer |
| Human approval points | §8, §3 | orchestrator `SKILL.md` HITL steps |
| Repo files (PLAN.md, etc.) | §12, §13 assets list | `assets/*.template.md` via implementer |
| Architecture / domain | §1–§5 | Consider `designer` re-run for architecture |
| New delegate skill | §6, §13, §14 | Do not copy delegate SKILL bodies |

## Sync rule

When any of §3, §7, §13, §14 change, review **all four** for consistency before calling implementer.

Bundled copy `skills/<orchestrator>/references/HARNESS_DESIGN.md` is **generated and read-only** (carries a `GENERATED COPY — do not edit` banner). Edit the canonical `harness-designs/<orchestrator>/HARNESS_DESIGN.md`, then run **implementer** to regenerate the bundled copy. Never hand-edit the bundled copy — even a one-liner — or design drift is silently reintroduced.

## Direct orchestrator edit (rare)

Allowed without full implementer when:

- Typo in `SKILL.md` only
- User says "quick fix, no design change"

Otherwise prefer: design first → implementer sync.

## Drift detection (system trigger)

Compare:

| Check | Design | Orchestrator |
|-------|--------|--------------|
| Delegate names | §6 table | `references/skill-delegation.md` |
| Gates | §7 commands | `SKILL.md` verification section |
| Batch steps | §14 batch flow | `SKILL.md` ## Workflow diagrams |
| §14 full | design §14 | `assets/workflow.mermaid.md` |

Any mismatch → patch design → `implementer` with `HARNESS_DESIGN_PATH`.

## Optional logs

Append user feedback snippets to `harness-designs/<orchestrator>/FEEDBACK.log` when the session spans many messages.
