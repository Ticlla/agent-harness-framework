# Parse HARNESS_DESIGN.md (§13 + §14)

Read the design file once; extract both implementation and diagram sections.

## §13 — Skill implementation plan

See `parse-section-13.md` for table fields and orchestrator name.

## §14 — Workflow diagrams (Mermaid)

Heading: `## 14. Workflow diagrams (Mermaid)` (suffix may vary).

Extract every fenced block:

```markdown
```mermaid
...
```
```

### Required diagrams

| Diagram | Typical heading | Destination in orchestrator |
|---------|-----------------|------------------------------|
| Skill bundle | `### Skill bundle` | `assets/workflow.mermaid.md` + optional embed in SKILL.md |
| Batch flow | `### Orchestrator batch flow` | `assets/workflow.mermaid.md` + **embed** in SKILL.md `## Workflow diagrams` |
| Verification | `### Per-test verification` or `### Verification gates` | `assets/workflow.mermaid.md` only |

### If §14 missing

1. Read §3, §13 ASCII graph, §6 delegates, §7 gates.
2. Build diagrams per `../../designer/references/mermaid-diagrams.md`.
3. Write `assets/workflow.mermaid.md` in the orchestrator.
4. **Append §14 to the source design** at `HARNESS_DESIGN_PATH` (under `harness-designs/<orchestrator>/`) so design and runtime stay aligned.

### If §14 invalid

Fix Mermaid syntax (node IDs, quotes on labels). Update design file §14 before packaging.

## Consistency check

Before `package_skill.py`:

- Batch flow nodes cover every §3 behavior bullet
- Skill bundle includes `designer`, `implementer`, orchestrator name, all §6 delegates
- Gate diagram commands match §7 shell blocks (labels may abbreviate)

## Executable-artifact preflight

If the design's deliverable is an artifact that **runs** (codemod, transform, generator, script) and §7 contains only presence/shape checks (file exists, matcher present) with **no executed gate** that runs the artifact against its fixtures, **flag it and pause**: presence-only is not a valid definition of done for executable output. Require the design to add an execution gate + a dependency-reality check before the build is considered complete (see `../../designer/references/domain-profiles.md` → Executable-artifact gate, and the handoff checklist).
