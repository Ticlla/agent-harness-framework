# Agent Harness Framework

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> The framework for building agent harness pipelines.

Meta-skills and design catalog for building **gate-verified orchestrator workflows** in Cursor and other agent CLIs.

Domain skills (code review, req-doc generation, Playwright migration, etc.) live in a **sibling repository** with a `skills/` tree (for example `../agent-skills/`). This repo owns the **pipeline** that designs, builds, validates, and improves harness orchestrators.

> **Hosting:** clone or fork to your own remote; paths below assume a local sibling layout.

## Prerequisites

| Need | Why | Notes |
|------|-----|-------|
| **Python 3.8+** | `skill-creator` scripts (`init_skill.py`, `package_skill.py`, `quick_validate.py`) — stdlib only, no `pip` | Windows: `python3` is usually **not** on PATH. Use `python` or `py -3` (e.g. `py -3 skills/skill-creator/scripts/quick_validate.py skills/<name>`). |
| **POSIX shell** | `scripts/install.sh` | Windows: run under **Git Bash** or **WSL**. |

## Quick start

Clone both repos as **siblings** so delegate discovery works:

```text
your-workspace/
├── agent-harness-framework/   ← this repo (meta-skills + harness-designs/)
└── <domain-skills-repo>/     ← delegate skills (e.g. agent-skills)
```

**Visual guide:** open [docs/harness-framework/visual/harness-framework-overview.html](docs/harness-framework/visual/harness-framework-overview.html) in a browser.

**Presentation slides:** [docs/harness-framework/visual/harness-framework-slides.html](docs/harness-framework/visual/harness-framework-slides.html) — full-screen deck (arrow keys / Space).

**New here?** [What is a harness?](docs/harness-framework/what-is-a-harness.md) · [Should I use this?](docs/harness-framework/should-i-use-this.md) · [Pipeline stages](docs/harness-framework/README.md)

## Pipeline

```text
designer → implementer → validator → run → (enhancer on failure)
```

| Skill | Role |
|-------|------|
| `designer` | Writes `harness-designs/<orchestrator>/HARNESS_DESIGN.md` (§13+§14) |
| `implementer` | Scaffolds `skills/<orchestrator>/` via `skill-creator` |
| `validator` | Smoke-runs one worklist item; writes `VALIDATION_REPORT.md` |
| `enhancer` | Repairs design/build from failure signals |
| `skill-creator` | Init/package orchestrator skills (used by implementer) |

Load the skill index from [AGENTS.md](AGENTS.md) before running any meta-skill.

## Repository layout

```text
skills/                  Meta-skills + skill-creator
harness-designs/         Canonical designs + validation reports (catalog in README.md)
docs/harness-framework/   Onboarding docs, diagrams, visual HTML guide
```

Orchestrator **runtime skills** may be authored here or in another repo — §13 **Orchestrator home** in each `HARNESS_DESIGN.md` records where the implementer scaffolds. **Delegate skills** are resolved by name from sibling repos (`../*/skills/`), installed skill dirs, and this repo.

## Environment variables

| Variable | Purpose |
|----------|---------|
| `HARNESS_DESIGN_PATH` | Override path to `HARNESS_DESIGN.md` for implementer/validator/enhancer |

## Validate meta-skills

```bash
python3 skills/skill-creator/scripts/quick_validate.py skills/designer
python3 skills/skill-creator/scripts/quick_validate.py skills/implementer
python3 skills/skill-creator/scripts/quick_validate.py skills/validator
python3 skills/skill-creator/scripts/quick_validate.py skills/enhancer
```

## Installing skills locally

Use the bundled installer to copy the five meta-skills into your agent runtime:

```bash
./scripts/install.sh                          # copy into ~/.claude/skills (default)
./scripts/install.sh install --target cursor  # copy into ~/.cursor/skills
./scripts/install.sh status                   # show what is installed where
./scripts/install.sh uninstall -y             # remove them (leaves other skills alone)
```

Copies are self-contained — you can move or delete this repo afterwards and the
skills keep working. Update later with `git pull && ./scripts/install.sh`.

Options: `--link` (symlink to this repo instead of copying, tracks `git pull` live),
`--target <path>` (any directory), `--skills a,b,c` (subset), `--help`.

<details><summary>Manual install (no script)</summary>

```bash
# Cursor example — symlink each meta-skill into your skills dir
for s in designer implementer validator enhancer skill-creator; do
  ln -sfn "$(pwd)/skills/$s" ~/.cursor/skills/$s
done
```

</details>

Also install domain skills from your sibling delegate repo when a harness references them.

## Related repos

| Repo | Contents |
|------|----------|
| Sibling `*/skills/` repo | Domain skills used as harness delegates (path recorded in each design §6) |
| Target app repos | Optional home for built orchestrator skills (§13) |

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full workflow. In short:

1. Design changes → `harness-designs/<orchestrator>/HARNESS_DESIGN.md` (canonical; never edit generated copies under `skills/<orchestrator>/references/` by hand).
2. Meta-skill changes → `skills/{designer,implementer,validator,enhancer}/`.
3. Run `quick_validate.py` on touched skills before opening a PR.

This project follows the [Contributor Covenant](CODE_OF_CONDUCT.md) code of conduct.

## License

[MIT](LICENSE) — © 2026 Alcides Ticlla.
