---
name: {ORCHESTRATOR_NAME}
description: {FROM_SECTION_13_AGENTS_INDEX_LINE}
---

# {ORCHESTRATOR_TITLE}

Orchestrate **{TASK_SUMMARY}**. Owns loop, gates, worklist, and handoff — not delegate sub-workflows.

**Spec:** `{HARNESS_DESIGN_PATH}`

## When to use

{TRIGGERS_FROM_SECTION_13}

Do **not** use for: {ANTI_TRIGGERS — delegate skills, designer, implementer, skill-creator}

## Prerequisites

{DELEGATE_SKILLS_AND_EXTERNAL_GAPS}

## Workflow

{WORKFLOW_GRAPH_AS_NUMBERED_STEPS}

## Workflow diagrams

See `assets/workflow.mermaid.md` for full diagrams. Canonical batch flow:

```mermaid
{EMBED_BATCH_FLOWCHART_FROM_SECTION_14}
```

## Verification gates

```bash
{COPY_FROM_HARNESS_DESIGN_SECTION_7}
```

## Fail-closed rules

{FROM_SECTION_3_AND_9 — bullet list}

## Resources

| Path | Purpose |
|------|---------|
| `references/harness-spec.md` | Condensed spec |
| `references/skill-delegation.md` | Delegate loading rules |
| `{HARNESS_DESIGN_PATH}` | Full design |
