# Harness primitives reference

Agent = **model** + **harness**. Everything that is not the model is harness. Use this map to structure HARNESS_DESIGN.md sections.

## Core primitives

| Primitive | Problem solved | Typical Cursor artifacts |
|-----------|----------------|-------------------------|
| Agent loop | Turn structure, termination, retries | Rules for when to stop; hook stages |
| Planning & decomposition | Long tasks exceed one context | PLAN.md, milestones, scope boundaries |
| Context delivery & compaction | Context rot, cost, wrong scope | Rules for what to read; skills for retrieval |
| Tool design | Model cannot act on the world | MCP, built-in tools, schema discipline |
| Skills & MCP | Domain workflows, integrations | `.cursor/skills`, MCP server list |
| Permissions & authorization | Safety, least privilege | AGENTS.md allow/deny; approval hooks |
| Memory & state | Cross-session continuity | Memory files, journals, vector stores |
| Task runners & orchestration | Parallelism, subagents | Subagent rules, handoff format |
| Prompt self-management (runtime) | Orchestrator must reformulate or improve its own sub-prompts mid-run (long, ambiguous, failure-prone tasks) | Self-reflection loop, sub-prompt decomposition, candidate-selection rules |
| Verification & CI | Prove work before "done" | Commands in rules; eval criteria |
| Observability & tracing | Debug agent behavior | Logging conventions, trace review |
| Human-in-the-loop | Judgment, brand, risk | Explicit pause points |
| Security & sandbox | Isolation, secrets | Sandbox config, secret hygiene |

## Runtime self-prompting patterns

When a task is long, ambiguous, or failure-prone, the orchestrator may need to
**manage its own prompts at runtime** — decide what to ask itself next, not just
execute a fixed script. This is the runtime counterpart to the design-time
`prompt-engineering` consultation in designer step 6a. Declare only the patterns
the task profile requires; justify each in §4. **Minimal by default** — these add
cost and recursion risk, so do not sprinkle them across every harness.

| Pattern | When | Mechanism |
|---------|------|-----------|
| **Self-reflection loop** (Reflexion) | Output quality matters and failures are observable | After a step, the orchestrator critiques its own output against the spec, writes a concrete fix, and retries the weak sub-step. Bounded retries (e.g. ≤2). |
| **Meta-prompting decomposition** | One goal spans several distinct expert sub-tasks | The orchestrator decomposes the goal into specialized sub-prompts and routes each — it decides the sub-prompt, not just the answer. |
| **Candidate selection** (APE-style) | The right prompt shape is unknown but evaluable, and the prompt is reused many times | Generate N candidate sub-prompts, run each against a cheap eval, keep the best. Costly — only for high-reuse prompts. |

**Guardrails (required when declaring any of these):**

- **Bound recursion:** cap reflection rounds and candidate counts as a §7-style gate, or the loop runs away.
- **Reuse the vendored `prompt-engineering` skill for the brakes:** `<constraints>` (anti-scope-drift), `<self_check>` (high-risk re-scan), and the failure taxonomy that `enhancer` consumes on miss — see `../../prompt-engineering/references/`.
- **Map to an implementation** (principle 5): the loop usually lives as rules in the orchestrator skill; the guardrails are delegate/`prompt-engineering` references.
- **Flag model sensitivity:** Reflexion and candidate selection behave differently across model families. Note portability in §4 (co-evolution warning) and prefer them for models that follow long, structured instructions reliably.

## Design principles (always apply)

1. **Behavior → harness feature:** State desired agent behavior, then name the harness component that enables it.
2. **Assume expiry:** Document what model improvement would make each component removable (see templates/HARNESS_CHECKLIST.md).
3. **Feedforward + feedback:** Combine instructions (feedforward) with automated checks (feedback) before human review.
4. **Minimal by default:** Add primitives only when the task profile requires them; justify each in HARNESS_DESIGN.md.
5. **Skills implement runtime:** Map each primitive to either a **delegate skill** (existing), **orchestrator skill** (new via skill-creator), or **repo rules/files** (§12). See `implementation-via-skills.md`.

## Co-evolution warning

Models trained with specific harness shapes may overfit to them. When recommending unusual patterns, note portability and vendor lock-in.
