# EnhancementBrief

A short contract produced **before** file edits. Keeps multi-message user feedback coherent.

## Required fields

| Field | Description |
|-------|-------------|
| **Date** | ISO date |
| **Mode** | `meta-only` \| `instance-only` \| `full-loop` |
| **Orchestrator** | kebab-case name, or `(none)` for meta-only |
| **Trigger** | `user` \| `system` |
| **Problem** | What is wrong in one paragraph |
| **Root cause** | Hypothesis: meta gap, instance drift, runtime, unclear spec |
| **Target files** | Explicit list of paths to edit |
| **Out of scope** | What will not be changed |
| **Patches** | Numbered list of concrete edits |
| **Re-run plan** | `none` \| `designer` \| `implementer` \| `both` + scope notes |
| **Validation** | Checklist items to run after patches |

## Optional fields

| Field | Description |
|-------|-------------|
| **Source messages** | Bullet summary of user turns (not full paste) |
| **Lesson for meta** | If instance-only: should this become a template rule? |
| **Version after** | New design version number if instance updated |

## Persistence

| Location | When |
|----------|------|
| Chat only | Small, meta-only, or user prefers no files |
| `harness-designs/<orchestrator>/ENHANCEMENT.md` | Instance or full-loop with non-trivial instance change |
| `harness-designs/_meta/ENHANCEMENT-<date>.md` | Large meta-only audit trail (optional) |

## Approval

Confirm with the user when:

- More than 3 files change
- Orchestrator rename/delete
- User has not said to apply yet

For a single clear fix ("add §7 command X to jet-p0"), brief in chat and apply is acceptable.
