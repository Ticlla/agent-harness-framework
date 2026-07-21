# Contributing

Thanks for your interest in improving the Agent Harness Framework. This repo holds the **meta-skills** that design, build, validate, and improve harness orchestrators, plus the canonical `harness-designs/` catalog.

## Ways to contribute

- Bug reports and fixes for the meta-skills (`skills/{designer,implementer,validator,enhancer}`, `skills/skill-creator`)
- Improvements to onboarding docs (`docs/harness-framework/`)
- New domain profiles, references, or templates that benefit all harnesses
- Validation-report or design-layout refinements

## Before you start

Read [AGENTS.md](AGENTS.md) (skill index) and the relevant [docs/harness-framework/](docs/harness-framework/) guides so the change fits the pipeline model:

```text
designer → implementer → validator → (enhancer on failure)
```

## Workflow

1. **Fork & branch** from `main`. Use a descriptive branch name (e.g. `fix/validator-preflight-contract`).
2. **Make your change.** Match the surrounding tone, comment density, and structure.
3. **Validate any skill you touched:**

   ```bash
   python3 skills/skill-creator/scripts/quick_validate.py skills/<name>
   ```

   Every meta-skill (`designer`, `implementer`, `validator`, `enhancer`) must pass before a PR is merged.
4. **Commit.** Keep commits focused; write a clear message that explains *why*.
5. **Open a Pull Request** against `main` and fill in the PR template.

## Canonical-design rule

- The single source of truth for a harness is `harness-designs/<orchestrator>/HARNESS_DESIGN.md`.
- Generated copies under `skills/<orchestrator>/references/` are **read-only** — never edit them by hand; regenerate via `implementer`.
- Meta-skill changes go in `skills/{designer,implementer,validator,enhancer}/`.

## Security & secrets

- Do **not** commit secrets, API keys, tokens, or local settings (`.claude/` is gitignored).
- If you discover a security issue, see the private disclosure path rather than a public issue.

## Commits & history

- Keep history clean and reviewable. Squash-worth changes are fine; avoid force-pushing to `main` once a PR is public.

## Licensing

By contributing, you agree your changes will be licensed under the [MIT License](LICENSE).
