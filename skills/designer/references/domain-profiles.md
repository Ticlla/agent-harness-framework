# Domain profiles for harness design

Use these profiles to bias primitive selection. A profile is not a rigid template — override when the user's constraints demand it.

## How to classify

| Signals in user request | Profile |
|-------------------------|---------|
| PR review, diff, lint, standards, security review | `codereview` |
| Test generation, coverage, CI, eval harness, flaky tests | `test` |
| UX, UI, specs, design tokens, Figma, accessibility | `design` |
| Copy, campaigns, brand, SEO, content calendar | `marketing` |
| Feature implementation, refactor, bugfix in a codebase | `coding` |
| Incidents, deploy, SRE, observability, runbooks | `ops` |

If multiple apply, pick the **primary outcome** (what "done" means) and note secondary concerns in HARNESS_DESIGN.md.

For agent-enabled repos, also note which **existing skills** under `skills/` are likely delegates (§6) vs whether a new **orchestrator skill** is needed (§13). Complete **§14 Mermaid** in the same session, then `implementer`. See `design-implementer-handoff.md`.

## Profile: codereview

**Goal:** Correct, scoped feedback on changes without rewriting the whole repo.

| Priority | Primitive | Cursor-oriented lever |
|----------|-----------|------------------------|
| High | Verification loop | Rules that require running tests/linters on touched paths |
| High | Context delivery | Diff-first context; exclude unrelated modules |
| High | Permissions | Read-mostly; write only on explicit ask |
| Medium | Tool design | Small tools: `git diff`, static analysis, not broad shell |
| Low | Long-horizon planning | Skip PLAN.md unless multi-PR arc |

**Risks to call out:** Context bloat from full-repo reads; ambiguous "approve" without verification commands.

## Profile: test

**Goal:** Reliable tests and eval signals, not one-off scripts.

| Priority | Primitive | Cursor-oriented lever |
|----------|-----------|------------------------|
| High | Verification & CI | Explicit test commands in rules; fail-closed completion |
| High | Sandbox | Isolated test env; no prod credentials |
| Medium | Tool design | Test runner, coverage, fixture helpers |
| Medium | Agent loop | Plan → implement test → run → fix loop |
| Low | Marketing / brand context | Omit unless testing content pipelines |

**Migration/porting sub-type (source repo → target repo).** When the harness translates artifacts (tests, code, configs) from a source to a target, the design **must** add two orchestrator-level gates (the conversion *delegate* authors the output; the harness only gates + tracks):
- **Fidelity parity:** every source assertion/behavior is represented in the target output or **explicitly waived with a reason**. No silent erosion. A soft heuristic (e.g. target assertion count < source check count → ⚠️) can feed a human review.
- **Source→target data/dependency mapping:** map source fixtures/data/env to target equivalents; on **no equivalent**, escalate / mark `blocked` — never fabricate. Record mappings in the memory file.

**Executable-artifact gate (any profile whose deliverable *runs*).** When the harness produces an artifact that executes — a codemod, transform, generator, or script — presence of the right files is **never** a sufficient definition of done. §7/§8 **must** include:
- an **execution gate** — the artifact runs green against its own fixtures (a shape/presence check can pass a transform that throws on every input);
- a **dependency-reality check** — every declared version pin resolves to a published release before the artifact is registered or trusted (a fictional pin fails install and is caught here, not at first run).

Rationale: shape-grading once scored a codemod 6/6 that threw on every fixture and pinned a non-existent dependency version — both invisible until the artifact was actually executed.

## Profile: design

**Goal:** Human-aligned visuals and specs with iterative feedback.

| Priority | Primitive | Cursor-oriented lever |
|----------|-----------|------------------------|
| High | Human-in-the-loop | Checkpoints before implementation commits |
| High | Context delivery | DESIGN.md / tokens; progressive spec loading |
| Medium | Filesystem artifacts | Specs and session notes as durable files |
| Medium | Memory | Persist design decisions across sessions |
| Low | Autonomous code execution | Constrain until spec approved |

## Profile: marketing

**Goal:** On-brand, reviewable content with guardrails.

| Priority | Primitive | Cursor-oriented lever |
|----------|-----------|------------------------|
| High | Human-in-the-loop | Brand/legal review gates |
| High | Permissions | No publishing credentials in agent context |
| High | Context delivery | Brand guidelines, tone, audience in scoped files |
| Medium | Skills / MCP | CMS or analytics only if explicitly needed |
| Low | Code execution sandbox | Minimize unless landing-page/code tasks |

## Profile: coding (default implementation)

**Goal:** Ship correct code with agent-first velocity.

| Priority | Primitive | Cursor-oriented lever |
|----------|-----------|------------------------|
| High | Agent loop | Observe → plan → act → verify |
| High | Context delivery | Scoped reads; compaction for long tasks |
| High | Verification | Tests + lint as completion gates |
| Medium | Planning artifacts | PLAN.md for non-trivial work |
| Medium | Tool design | Minimal, composable tools |
| Medium | Sandbox & permissions | Least privilege |

## Profile: ops

**Goal:** Safe automation against production systems.

| Priority | Primitive | Cursor-oriented lever |
|----------|-----------|------------------------|
| High | Permissions & authorization | Explicit allowlists; no silent prod changes |
| High | Observability | Log/trace discipline in rules |
| High | Verification | Dry-run, backtest, rollback plans |
| Medium | Memory | Incident notes, runbooks as files |
| Medium | Human-in-the-loop | Approval for mutating actions |
