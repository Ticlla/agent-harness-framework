# Agent Harness Framework

See [README.md](README.md) and [AGENTS.md](AGENTS.md) for orientation.

## Repository role

This repo is the **home for harness framework meta-skills** and the **canonical `harness-designs/` catalog**. Domain delegate skills live in a sibling repo (see README).

## Key paths

| Path | Role |
|------|------|
| `skills/designer/` | Design harnesses → `harness-designs/<orch>/HARNESS_DESIGN.md` |
| `skills/implementer/` | Build orchestrator skills from §13+§14 |
| `skills/validator/` | Smoke validation → `VALIDATION_REPORT.md` |
| `skills/enhancer/` | Repair loop from failure signals |
| `skills/skill-creator/` | Init/package orchestrators (implementer dependency) |
| `skills/prompt-engineering/` | Vendored advisory skill — prompt techniques, audit checklist, model guides; consulted on demand (see its `PROVENANCE.md`) |
| `harness-designs/` | Canonical designs; generated copies under `skills/<orch>/references/` are read-only |
| `docs/harness-framework/` | Onboarding and visual guide |

## Conventions

- **Canonical design:** edit only `harness-designs/<orchestrator>/HARNESS_DESIGN.md`.
- **Orchestrator home:** §13 may point to this repo's `skills/` or an external repo.
- **Delegates:** discovered from sibling `../*/skills/`, `~/.cursor/skills`, `~/.claude/skills`, and paths in each design §6.
- **Validate skills:** `python3 skills/skill-creator/scripts/quick_validate.py skills/<name>` (Python 3 required — stdlib only; Windows: use `python` or `py -3`, since `python3` is rarely on PATH)

## Do not commit unless asked

Wait for explicit user confirmation before `git commit` or `git push`.
