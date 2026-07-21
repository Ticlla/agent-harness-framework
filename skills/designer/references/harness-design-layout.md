# Harness design layout (multi-harness repo)

This repository ships **installable skills** under `skills/` and **design sources** under `harness-designs/`. One harness = one orchestrator skill + one design folder.

## Paths

| Purpose | Path |
|---------|------|
| Design (canonical, edit here) | `harness-designs/<orchestrator>/HARNESS_DESIGN.md` |
| Catalog | `harness-designs/README.md` |
| Runtime skill | `skills/<orchestrator>/` |
| Design copy (ships with skill zip) | `skills/<orchestrator>/references/HARNESS_DESIGN.md` |
| Root pointer only | `HARNESS_DESIGN.md` → links to catalog |

`<orchestrator>` must match §13 **New orchestrator skill name** (kebab-case, suffix `-harness` recommended).

## Catalog (`harness-designs/README.md`)

This repo ships an empty catalog at `harness-designs/README.md` (header + column row only). Any skill that "updates the catalog" must **append rows there**; **create the file from the template below only if missing** (e.g. in a fork without the file) using exactly this shape (do not invent columns):

```markdown
# Harness designs catalog

| Orchestrator | Domain | Design | Home | Status |
|--------------|--------|--------|------|--------|
| <name> | <domain profile> | harness-designs/<name>/HARNESS_DESIGN.md | skills/ (or ../<repo>/skills/) | designed \| built \| validated \| stale |
```

- **Home** records where the orchestrator skill is authored (this repo's `skills/` by default; an external repo path otherwise).
- **Status** tracks pipeline progress: `designed` (designer done) → `built` (implementer done) → `validated` (validator passed) → `stale` (design changed after validation).
- One row per orchestrator. Append; never rewrite other rows.

## Designer output

Never overwrite another harness. Write only:

```
harness-designs/<orchestrator>/HARNESS_DESIGN.md
```

If §13 name is new, add a row to `harness-designs/README.md` — **creating the file from the Catalog template above if it does not exist yet.**

## Handoff to implementer

```text
HARNESS_DESIGN_PATH=harness-designs/<orchestrator>/HARNESS_DESIGN.md
```

## Install behavior (Cursor / the agent)

Users install `skills/<orchestrator>/` only. They do **not** need `harness-designs/` unless they maintain the repo. The orchestrator's `references/HARNESS_DESIGN.md` is the bundled spec.

## Meta skills (always under skills/)

- `designer` — writes `harness-designs/`
- `implementer` — reads `HARNESS_DESIGN_PATH`, writes `skills/<orchestrator>/`
- `enhancer` — feedback loop on meta skills and/or one instance; may re-run designer/implementer
- `skill-creator` — init/package (used by implementer)
