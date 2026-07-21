# Meta patch guide (designer / implementer)

Edit **only** what fixes the generalized failure. Prefer references and checklists over rewriting full `SKILL.md` files.

## Common feedback → target files

| Feedback theme | Primary targets |
|----------------|-----------------|
| §13/§14 handoff incomplete | `designer/references/design-implementer-handoff.md`, both skills' handoff sections |
| §14 Mermaid rules unclear | `designer/references/mermaid-diagrams.md` |
| §13 template missing fields | `designer/assets/HARNESS_DESIGN.template.md` |
| Implementer skips §7 in orchestrator | `implementer/references/orchestrator-file-checklist.md`, `implementer/SKILL.md` step 5 table |
| §13 parse errors | `implementer/references/parse-section-13.md`, `parse-design-input.md` |
| Pipeline diagram outdated | `designer/references/implementation-via-skills.md` |
| Multi-harness path confusion | `designer/references/harness-design-layout.md` |
| Enhancer should be mentioned | `designer/SKILL.md`, `implementer/SKILL.md` relationship tables |

## Editing rules

1. **Smallest diff** — one section per root cause when possible.
2. **English** in repo docs unless user requests otherwise.
3. **Do not** change delegate skills (`jet-smoke-to-playwright`, `fusion-worktree`, …).
4. After editing designer references used by implementer, note in EnhancementBrief if **open** implementer sessions need re-read.
5. **Package** — run `package_skill.py` on designer/implementer only if user asked to ship zips; not required for every meta tweak.

## When meta patch is enough (no re-run)

- Wording/clarification in handoff doc
- New optional checklist item
- Cross-link to `enhancer`

Re-run **designer/implementer on an instance** only when user wants to **regression-test** a harness against new rules.

## skill-creator

Enhancer does **not** run `init_skill.py` on meta skills unless user asks to rescaffold. Use direct edits to `SKILL.md` and `references/`.
