# Workflow diagrams — {ORCHESTRATOR_NAME}

> Template for HARNESS_DESIGN.md §14. implementer copies to `skills/{ORCHESTRATOR_NAME}/assets/workflow.mermaid.md`.

## Skill bundle

```mermaid
flowchart LR
  HD[designer] -->|HARNESS_DESIGN.md| HI[implementer]
  HI -->|creates| OR[{ORCHESTRATOR_NAME}]
  OR --> HV[validator]
  OR --> D1[{DELEGATE_1}]
  OR --> D2[{DELEGATE_2}]
```

## Orchestrator batch flow

```mermaid
flowchart TD
  Start([Start]) --> Intake[Intake]
  Intake --> Setup[Setup / worktree]
  Setup --> Loop{More work?}
  Loop -->|yes| Work[Delegate sub-workflow]
  Work --> Gates[Verification gates]
  Gates --> Pass{Pass?}
  Pass -->|no| Work
  Pass -->|yes| Loop
  Loop -->|no| HITL[Human review]
  HITL --> End([End])
```

## Verification gates (optional)

```mermaid
flowchart LR
  G1[gate 1] --> G2[gate 2] --> OK([done])
```
