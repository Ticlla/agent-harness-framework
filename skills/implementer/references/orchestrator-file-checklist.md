# Orchestrator skill file checklist

After `init_skill.py <name> --path skills`, ensure:

## Required

- [ ] `SKILL.md` — frontmatter `name` + `description`; workflow; §7 gates; fail-closed; pointer to `references/HARNESS_DESIGN.md`
- [ ] §7 gates copy-paste-ready: no unresolved `<placeholder>` mixed with concrete paths for the same arg; scope checks use `git status --porcelain` (catches untracked), not `git diff --name-only`
- [ ] §7 gate command is **verified-runnable**, not just a `package.json` script name. Confirm/state: **where to run it from** (main checkout vs worktree — if the harness mandates a worktree, check the runner doesn't ignore it via `testIgnore` / `**/.worktrees/**`), required **env/baseURL** (scripts often default to localhost / a dev server that must be up → otherwise connection-refused), and the real **filter mechanism** (flag vs env var; wrappers may reject `--grep`). A gate that "exists" but yields "No tests found" or `ECONNREFUSED` is a preflight failure.
- [ ] `references/harness-spec.md` — operational summary (not full design paste)
- [ ] `references/skill-delegation.md` — when to load each delegate; **for transform delegates** (send, codemod, path rewrite), one line per delegate on **input contract** (orchestrator passes X unchanged → delegate emits Y)
- [ ] `references/HARNESS_DESIGN.md` — generated read-only copy of `harness-designs/<orchestrator>/HARNESS_DESIGN.md` (bundled for install; starts with `<!-- GENERATED COPY — do not edit. Canonical: harness-designs/<orchestrator>/HARNESS_DESIGN.md -->`)

## Required (diagrams — §14 contract)

- [ ] `assets/workflow.mermaid.md` — full copy of design §14 (all mermaid blocks)
- [ ] `SKILL.md` section `## Workflow diagrams` — embed batch `flowchart TD` from §14
- [ ] Source `harness-designs/<orchestrator>/HARNESS_DESIGN.md` §14 present (backfilled if implementer derived it)
- [ ] Skill-bundle diagram in `workflow.mermaid.md` lists `designer`, `implementer`, orchestrator, §6 delegates

## Optional (per §13)

- [ ] `assets/*.template.md` — repo artifacts orchestrator copies to worktree
- [ ] `scripts/` — only if §13 requires deterministic automation

## Must not include

- Copied phases from delegate skills
- Full design rationale / §11 notes (stay in `harness-designs/.../HARNESS_DESIGN.md` and orchestrator `references/HARNESS_DESIGN.md`)
- Duplicate `designer` or `implementer` workflows

## Quality bar

- Orchestrator `SKILL.md` under ~120 lines
- Description triggers distinct from delegates (batch/loop/gates vs single conversion)
