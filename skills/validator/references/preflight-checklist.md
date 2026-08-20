# Preflight checklist (light, fail-fast)

A **sanity gate** before the smoke-run — confirm the orchestrator is *runnable*, not *correct*. Deep design↔skill drift is the enhancer's job (`../../enhancer/references/instance-patch-guide.md`); do **not** duplicate that full matrix here.

If **any** item fails → stop, do not smoke-run, emit a `failed` report with the failure signal (see `enhancer-handoff.md`).

## Checks (orchestrator-skill mode)

*These checks apply only when validating an orchestrator skill. For rules-only mode, skip these and proceed to the **rules-only branch** section below.*

0. **Sweep orphaned worktrees (housekeeping)** — a prior validation interrupted before teardown (API timeout, manual stop, shell crash) leaks its throwaway worktree under `/tmp/hv-<orchestrator>-*`. Clear stale ones **scoped to this orchestrator** before creating a new one — do **not** blanket-`rm` `/tmp/hv-*`, a different orchestrator may be validating concurrently:
   ```bash
   # <target> = §2 target repo path
   git -C <target> worktree prune
   ls -d /tmp/hv-<orchestrator>-* 2>/dev/null | xargs -r rm -rf
   git -C <target> worktree prune
   ```
   Non-fatal: log what was removed, never fail preflight on it.
1. **Files present** — `skills/<orchestrator>/`:
   - `SKILL.md` (with `name` + `description` frontmatter)
   - `assets/workflow.mermaid.md`
   - `references/` (incl. `HARNESS_DESIGN.md` copy)
2. **§7 gates runnable-shaped** — each gate command in `SKILL.md` / design §7 has:
   - a concrete command (not a bare script name),
   - **where to run** it (repo root vs worktree),
   - the real **filter mechanism** (flag vs env var),
   - required env / baseURL noted (a script defaulting to localhost with no server → connection-refused).
   This checks *shape*, not execution — execution happens in the smoke-run.
2b. **Deterministic gates are machine-checked (§7 gate executability rule)** — classify every §7 gate:
   - **Executable** (command/script invocation) → pass.
   - **Labeled "§8 judgment gate"** (human judgment: fidelity, brand, pedagogy) → pass; it is §8 material, not a §7 command.
   - **Prose expressing a deterministic check** ("verify every claim has a citation", "ensure ≥N words", "check the path matches ...") → **fail**. A deterministic check (count, threshold, regex/form, path shape, presence, resolution) written as prose is unverifiable at runtime and rots into sign-off theater. Failure signal: `Trigger: system`, root cause `drift` (design defect — §7 gate not executable), suggested fix: designer converts the gate to a `scripts/` invocation.
   Rationale (real case): a pack harness marked a subject "done" while failing its word-count and grounding gates — both checks existed only as prose. Machine gates make "done" mean provable.
3. **§6 delegates resolve** — for every delegate named in §6 / `references/skill-delegation.md`:
   - resolve it to a concrete `SKILL.md` at the orchestrator home (this repo `skills/`, installed `~/.claude|.cursor/skills`, or a sibling `../<repo>/skills/`) and confirm that file is **readable** — a path that exists as a dir but has no readable `SKILL.md` is a fail.
   - for a delegate that ships a Python venv (`scripts/` + `.venv`), confirm `.venv/bin/python` exists at the resolved path — a missing interpreter means the behavioral run would crash on first delegation.
   - **Flag external delegates** (resolved outside this repo: `../<repo>/skills/` or an install dir) in the report as an **environment dependency** — the harness is only runnable where those paths are cloned/installed. A missing delegate = fail; a present-but-external delegate = pass-with-warning.
   The smoke-run itself is the real load test (it actually invokes each delegate); preflight only confirms the contract is reachable before spending a run.
4. **Declared dependency pins resolve** — for any version pin the design / orchestrator declares for an executable artifact (e.g. a codemod engine, transform library), confirm the pinned version is a **published, resolvable release** (e.g. it appears in the registry / installs). A fictional or unresolvable pin (`pkg@^4.0.0` when latest is `3.x`) = **fail** — it would break install before the artifact ever runs. Mirrors the external-delegate environment-dependency check above.

## rules-only branch

If §13 `Implementation mode` is **rules-only** (no orchestrator skill — see `../../implementer/references/rules-only.md`), there is no behavioral run. Validation is a **static artifact review** with these concrete checks:

1. **Artifacts exist** — the generated rule files are present at **every** target path the design names. Do not assume only `AGENTS.md` / `.cursor/rules/*`: a rules-only harness may also target agent-local instruction surfaces such as `CLAUDE.md` or files under `.claude/` (note: `.claude/` is gitignored, so confirm those by reading the local working tree, not git). Audit the **full** set the design enumerates — a rule surface left out of §4–§8 coverage is a silent gap.
2. **Render / parse clean** — files are valid for their format (e.g. front-matter parses, no unresolved `{PLACEHOLDER}` tokens left from a template).
3. **Reflect the design** — the rules actually encode §4–§8 (each design rule/constraint maps to a line in the artifact; no §7 gate silently dropped).
4. **No stray behavioral claim** — the artifact does not instruct loading an orchestrator skill that rules-only mode never built.

Then proceed straight to human sign-off on the generated artifacts and write the report with `Mode: rules-only` (Smoke-run = no). Skip the smoke-run and §7 gate *execution* entirely.
