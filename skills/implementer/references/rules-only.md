# Rules-only harness implementation

When §13 `Implementation mode` is **rules-only**, do **not** run `init_skill.py`.

## Steps

1. Confirm §12 repo artifacts (if any) — create templates in the **target repo**, not in a meta-skills repo's `skills/` tree.
2. Draft or update **target repo** `AGENTS.md` / `.cursor/rules` using §4–§8 from `HARNESS_DESIGN.md`.
3. List ad-hoc delegate skills from §6 for the user to load manually.
4. Handoff: no orchestrator skill; document path to rules files.

## Stop conditions

If the user expected an orchestrator but §13 says rules-only, confirm before proceeding.
