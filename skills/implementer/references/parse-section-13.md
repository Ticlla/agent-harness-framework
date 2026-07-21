# Parsing HARNESS_DESIGN.md §13

Read the design file and extract these fields for implementation.

## Locate §13

Heading must match: `## 13. Skill implementation plan` (optional "(required)").

## Required fields

| Field | Where to find | Used for |
|-------|---------------|----------|
| Implementation mode | §13 table row `Implementation mode` | `orchestrator skill` vs `rules-only` |
| Orchestrator name | Row `New orchestrator skill name` | `init_skill.py` argument |
| Orchestrator owns | Row `Orchestrator owns` | SKILL.md scope |
| Delegate skills | Row `Delegate skills` | `skill-delegation.md` |
| Gaps | Row `New skills needed` / `Gaps` | handoff warnings |
| assets/ templates | Row `assets/` | copy/create under orchestrator |
| AGENTS.md line | Row `AGENTS.md index line` | orchestrator YAML `description` + index table |

## Workflow graph

Copy the fenced block under `### Orchestrator workflow graph` verbatim into orchestrator planning; translate into numbered steps in orchestrator `SKILL.md`.

## Section 14 (Mermaid)

Handled by **`references/parse-design-input.md`** together with §13. Do not implement orchestrator until §14 is resolved.

## skill-creator next steps in §13

Treat as **historical hint** only — **`implementer`** replaces direct user execution of that list.

## Validation before scaffold

- [ ] §13 exists and is not empty
- [ ] Orchestrator name is kebab-case, no spaces
- [ ] At least one delegate OR explicit rules-only mode
- [ ] §7 verification commands present in design (copy into orchestrator SKILL.md)

## If fields are missing

Stop and ask the user to re-run `designer` or fill §13 manually. Do not invent orchestrator names or delegates.
