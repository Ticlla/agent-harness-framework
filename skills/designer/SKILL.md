---
name: designer
description: Designs — does not build — repeatable, gate-verified batch workflows (migration, porting, mass refactor, fleet upgrade) over many tests, files, or repos. Produces a HARNESS_DESIGN.md under harness-designs for implementer. Not for scaffolding skills/, running the orchestrator, or feedback-driven fixes.
---

# Harness designer

A **skill** teaches how to do one step; a **harness** is **workflow design** — a flow that composes skills (reusing existing delegates, flagging any missing as gaps) with harness-engineering principles applied: deterministic worklist, gates, a trial on one item first, isolation, and sign-off before the rest. See [`docs/harness-framework/what-is-a-harness.md`](../../docs/harness-framework/what-is-a-harness.md).

Design a **harness** for **Cursor / agent CLIs** and produce a complete design at **`harness-designs/<orchestrator>/HARNESS_DESIGN.md`** that **`implementer`** can execute without guessing. See `references/harness-design-layout.md`.

## Deliverables (all required)

| # | Artifact | Section |
|---|----------|---------|
| 1 | Architecture | §1–§12 in `harness-designs/<orchestrator>/HARNESS_DESIGN.md` |
| 2 | Implementation spec | **§13** Skill implementation plan (orchestrator name = folder name) |
| 3 | Visual workflow | **§14** Workflow diagrams (Mermaid) |

§13 and §14 are **one handoff package**. Do not finish without §14. See `references/design-implementer-handoff.md`.

This skill does **not** create `skills/<orchestrator>/` or run `init_skill.py`.

## When to use

- Design a harness (review, testing, migration, ops, …)
- Produce `harness-designs/<orchestrator>/HARNESS_DESIGN.md` before implementation
- Define Mermaid flows for the implementer to copy

Do **not** use for: implementing the orchestrator (`implementer`), feedback-driven fixes (`enhancer`), running migrations (`<orchestrator>`), or generic skill authoring (`skill-creator`).

## Inputs to collect (intake)

If missing, ask briefly (max one message):

1. **Task domain** — `references/domain-profiles.md`
2. **Outcome** — one sentence for "done"
3. **Constraints** — risk, autonomy, multi-session
4. **Real repos** — actual source repo(s) the harness reads and target repo(s) it writes (paths). Required if the harness operates on real codebases.
5. **Existing skills (multi-repo)** — delegates may live beyond this repo. **Discovery** scans this repo (`AGENTS.md`/`skills/`), the install dir (`~/.claude/skills`, `~/.cursor/skills`), and sibling repos (`../*/skills/`); **resolution is install-dir-authoritative** — see step 2.
6. **Orchestrator name** — kebab-case; becomes `harness-designs/<name>/` (must not collide with existing catalog in `harness-designs/README.md`)
7. **Orchestrator home** — repo/dir where the orchestrator skill will be authored. Default: this repo's `skills/`. May be another skills repo or install dir — record it in §13.

## Workflow

### 1. Classify domain

Map to `references/domain-profiles.md`; note hybrids in §2.

### 2. Inventory delegate skills (multi-repo)

**Discovery** may scan all skill locations (this repo, install dirs, sibling `../*/skills/`) to find what exists. **Resolution is install-dir-authoritative**: the orchestrator runtime loads delegates by name from the **install dir** (`~/.claude/skills`, or `~/.cursor/skills` for Cursor targets) — that is where the framework's `install.sh` puts its own skills and where sibling-repo skills must be installed or symlinked.

Rules:

1. **§6 must record the resolved install path** per delegate (e.g. `~/.claude/skills/<name>`) — not just a name or a sibling-repo path. The validator checks that exact path.
2. A delegate found only in a sibling repo (`../<repo>/skills/<name>`) and **not** present in the install dir is an **environment gap**: record it in §6 with the fix ("install/symlink `../<repo>/skills/<name>` into `~/.claude/skills/`") and flag it in §8 as a setup checkpoint — never assume the runtime will scan the sibling repo.
3. Shadowing: if the same skill name exists in more than one location, §6 records which one the install dir actually serves and notes the duplicates. Do not silently rely on scan order.

List delegates in §6 (reference only — do not copy their procedures). Do not propose creating a skill that already exists in any scanned location.

### 3. Ground-truth reconnaissance

**If the harness operates on real repos/codebases, inspect them before drafting — never invent paths, commands, or selectors.** Skip only for pure rules-only or abstract harnesses.

For each source and target repo:

- **Locate & confirm** the real paths exist (e.g. `../<repo>`); note the branch.
- **Run/verify commands** — derive from the actual test-runner config, `package.json` scripts, Makefile, etc. Use the real command (and project/flags), not a generic guess.
  - **Verify the command actually DISCOVERS + EXECUTES one target test, not just that the script exists.** Confirm: (a) required env/baseURL (a `package.json` script may default to localhost / a dev server that isn't running → connection-refused); (b) the real grep/filter mechanism (flag vs env var — the wrapper may reject `--grep`); (c) test-runner **ignore globs** (`testIgnore`, `testignore`, `.gitignore`-driven) — especially when the harness mandates a **worktree** the runner is configured to skip (e.g. `testIgnore: ['**/.worktrees/**']` → "No tests found"). Record the *verified* command (where to run it from, env, filter syntax) in §7, not the bare script name.
- **Worklist / selection source** — find the *deterministic* selector (tag, header, directory convention, manifest, suite file); avoid "ask the user".
  - **Verify coverage across the full tree, not one named suite/dir.** A single named suite/index is often incomplete and the true set may span several locations — enumerate by the real selector tree-wide and confirm the count.
  - **If the criterion has no explicit label** (e.g. "P0" with only a numeric `@priority` header), state the **inferred mapping** and flag it as a **human-confirmation point** in §3/§8 — do not silently pick one reading.
- **Existing conventions & prior art (target)** — test framework layout, page-object/fixture patterns, annotation/metadata conventions, and **work already done** the harness must skip.
- Capture concrete paths and commands for §2 (repos), §3 (worklist source), §5 (context), §7 (gates), §12 (artifacts/conventions).

A short `Explore`-style pass over both repos is usually enough. Record findings directly into the relevant sections.

### 4. Select primitives

Read `references/primitives.md` and the matching profile in `references/domain-profiles.md`. Pick the **minimal** primitive stack the task profile requires; justify each in §4.

### 5. Draft §1–§12

Use `assets/HARNESS_DESIGN.template.md`. Complete architecture, §6 delegates, §7 gates, §10 expiry. Fill §2 repos, §3 worklist source, §7 commands/paths, and §12 conventions **from step 3 recon** — not from assumption.

**§7 gate executability rule:** a gate expressing a **deterministic** check (count, threshold, regex/form, path shape, presence, resolution) MUST be an executable command or `scripts/` invocation — never prose for the model to "verify". Prose gates are only for **human-judgment** checks and must say so ("§8 judgment gate"). A deterministic check written as a checklist item is unverifiable at runtime — the validator's preflight fails it.

### 6. Draft §13 (implementation plan)

Fill orchestrator name (= output folder name), workflow summary, assets, AGENTS index line. See `references/implementation-via-skills.md`.

**Output path:** `harness-designs/<orchestrator>/HARNESS_DESIGN.md` (create directory if new harness).

### 6a. Sharpen the orchestrator prompt (named step — record the result)

The §13 orchestrator prompt *is* a system prompt. Consult the vendored `prompt-engineering` skill before finalizing it:

1. **Model guide** — load the guide matching the target runtime model from `../prompt-engineering/references/`: `claude-fable5-prompting.md` (Fable 5 / Opus 4.8), `gpt56-sol-prompting.md` (GPT-5.6), `gpt5-family-prompting.md` (GPT-5.x), or `gemini3-family-prompting.md` (Gemini). If the design does not pin a model, state that.
2. **Audit** — run the 8-dimension checklist in `../prompt-engineering/references/prompt-audit-checklist.md` on the drafted prompt; fix any Critical/Warning items you can.

Record a one-line self-report in §13 so the consultation is accountable, not silent:

```text
Prompt engineering: guide consulted = <which | none — model not pinned>; audit = <clean | N Critical / M Warning fixed>
```

This step is not gating — §13 is valid without it — but you must record the line either way.

### 7. Draft §14 (Mermaid) — same session as §13

1. Start from `assets/workflow.mermaid.template.md` (replace placeholders).
2. Follow `references/mermaid-diagrams.md`:
   - **Skill bundle** — designer → implementer → orchestrator → delegates
   - **Batch flow** — must match §3 behaviors and §13 graph
   - **Verification** (recommended) — §7 gates as `flowchart LR`
   - **Delegation graph** — orchestrator + §6 delegates, nodes are skill names, plain edges
3. Cross-check: every §6 delegate appears in the skill-bundle **and** delegation-graph diagrams.

### 8. Update catalog

Add or update the row in `harness-designs/README.md` for this orchestrator. The repo ships an empty catalog (header + columns only); **create the file from the Catalog template in `references/harness-design-layout.md` only if it does not exist yet** (e.g. in a fork without the file). The design always lives here, even when the orchestrator is authored in another repo. If the **orchestrator home** (§13) is an external repo, note that home in the catalog row so the implementer scaffolds in the right place.

### 9. Handoff to implementer

Run checklist in `references/design-implementer-handoff.md`.

Tell the user:

```text
Load implementer with:
  HARNESS_DESIGN_PATH=harness-designs/<orchestrator>/HARNESS_DESIGN.md
```

Do **not** run `init_skill.py` or `package_skill.py`.

## Output rules

- English unless requested otherwise
- §14 Mermaid must be valid (renderable) syntax
- Keep design doc and diagrams consistent with §3/§13
- §2 repos, §7 commands/paths/scope-lock, and §3 worklist source must be **derived from the real repo** (step 3 recon), never invented
- Every deterministic §7 gate must be an executable command/script — no prose-only deterministic checks; human-judgment gates must be labeled as such

## Relationship to other skills

| Skill | Role |
|-------|------|
| `designer` | This skill — `harness-designs/<orchestrator>/HARNESS_DESIGN.md` |
| `implementer` | Reads §13 + §14 → builds orchestrator |
| `enhancer` | Targeted improvements; may re-run this skill for § refreshes only |
| `skill-creator` | Used only by implementer |

## Resources

| Path | Purpose |
|------|---------|
| `references/design-implementer-handoff.md` | §13+§14 checklist |
| `references/mermaid-diagrams.md` | §14 rules + pipeline diagram |
| `references/implementation-via-skills.md` | Three-skill pipeline |
| `references/domain-profiles.md` | Domain priorities |
| `references/primitives.md` | Primitive catalog |
| `references/harness-design-layout.md` | Multi-harness paths |
| `../prompt-engineering/` | Vendored advisory skill — model-specific guides + 8-dimension prompt audit for the §13 orchestrator prompt (load on demand) |
| `assets/HARNESS_DESIGN.template.md` | Design skeleton |
| `assets/workflow.mermaid.template.md` | §14 starter |
