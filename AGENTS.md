# Agent Harness Framework — Skills

Meta-skills for designing, building, validating, and improving harness orchestrators. Load this index before any Agent Harness Framework work.

Domain delegate skills (e.g. `code-review`, `generate-req-doc`) live in a sibling repo with a `skills/` directory — clone it next to this repo (for example `../agent-skills/`).

## Skill index

| Skill | Description |
|-------|-------------|
| `designer` | Designs — does not build — repeatable, gate-verified batch workflows (migration, porting, mass refactor, fleet upgrade) over many tests, files, or repos. Produces `harness-designs/<name>/HARNESS_DESIGN.md` (§13+§14) for `implementer`. Not for scaffolding `skills/`, running the orchestrator, or feedback-driven fixes. |
| `implementer` | Builds or resyncs an orchestrator skill from an existing `HARNESS_DESIGN.md` (§13+§14; `HARNESS_DESIGN_PATH`). Scaffolds `skills/<name>/` via `skill-creator`, embeds §14 diagrams, packages. Also handles rules-only harnesses (`AGENTS.md` / `.cursor/rules`). Not for writing the design (`designer`) or smoke-validation (`validator`). |
| `validator` | Proves a built or resynced harness before production trust. Smoke-runs one real §3 worklist item in a throwaway git worktree (or static review for rules-only), executes §7 gates, records human sign-off in `VALIDATION_REPORT.md`. On failure, emits `enhancer` signal. Not for design, build, or full batch runtime. |
| `enhancer` | Improves meta pipeline skills and/or one harness instance from user feedback or failure signals (`VALIDATION_REPORT` fail, implementer preflight, design↔skill drift, runtime mismatch). Writes `EnhancementBrief`, patches targeted files, delegates `designer` / `implementer` / `validator` re-runs. Not for greenfield design or first-time build. |
| `skill-creator` | Guide for creating effective skills. Use when creating a new skill or updating an existing skill that extends capabilities with specialized knowledge, workflows, or tool integrations. Used by `implementer` to init and package orchestrator skills. |

Built orchestrator instances have migrated to standalone repos (siblings): `harness-anatomy` → `harness-anatomy-pipeline`; `notebooklm-study-pack` → `notebooklm-harness-framework`.

## Loading strategy

1. Match the task to a skill in the table above.
2. Load `skills/<skill-name>/SKILL.md`.
3. Load `references/` files only when the skill directs you to.
4. For delegate skills, load from the path in the harness design §6 (typically `../<domain-repo>/skills/<name>/SKILL.md`).

## Documentation

| Path | Purpose |
|------|---------|
| [docs/harness-framework/README.md](docs/harness-framework/README.md) | Pipeline stages and diagrams |
| [docs/harness-framework/what-is-a-harness.md](docs/harness-framework/what-is-a-harness.md) | Skill vs harness |
| [docs/harness-framework/should-i-use-this.md](docs/harness-framework/should-i-use-this.md) | Three-question decision rule |
| [harness-designs/README.md](harness-designs/README.md) | Design catalog |

## Pipeline order

```text
designer → implementer → validator → (enhancer on failure)
```
