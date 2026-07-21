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
| Verification & CI | Prove work before "done" | Commands in rules; eval criteria |
| Observability & tracing | Debug agent behavior | Logging conventions, trace review |
| Human-in-the-loop | Judgment, brand, risk | Explicit pause points |
| Security & sandbox | Isolation, secrets | Sandbox config, secret hygiene |

## Design principles (always apply)

1. **Behavior → harness feature:** State desired agent behavior, then name the harness component that enables it.
2. **Assume expiry:** Document what model improvement would make each component removable (see templates/HARNESS_CHECKLIST.md).
3. **Feedforward + feedback:** Combine instructions (feedforward) with automated checks (feedback) before human review.
4. **Minimal by default:** Add primitives only when the task profile requires them; justify each in HARNESS_DESIGN.md.
5. **Skills implement runtime:** Map each primitive to either a **delegate skill** (existing), **orchestrator skill** (new via skill-creator), or **repo rules/files** (§12). See `implementation-via-skills.md`.

## Co-evolution warning

Models trained with specific harness shapes may overfit to them. When recommending unusual patterns, note portability and vendor lock-in.
