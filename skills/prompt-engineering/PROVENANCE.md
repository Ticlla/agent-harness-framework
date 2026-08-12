# Provenance — `prompt-engineering`

This skill is **vendored** (not authored here) so the framework is self-contained:
a fresh clone of this repo gets it without any network fetch or extra dependency.

## Upstream source

| Field | Value |
|-------|-------|
| Repository | [CodeAlive-AI/ai-driven-development](https://github.com/CodeAlive-AI/ai-driven-development) |
| Path in upstream | `skills/prompt-engineering/` |
| Pinned commit | `224c4d20255812fa6df00d73b3d4362eea35e311` |
| Commit date | 2026-07-13 |
| Commit subject | `docs(prompt-engineering): add GPT-5.6 and Fable 5 guidance` |
| License | MIT (see `LICENSE`; Copyright (c) 2026 CodeAlive-AI) |

> The standalone `CodeAlive-AI/prompt-engineering-skill` repo is **archived** —
> the live upstream is the umbrella `ai-driven-development` repo above.

## What was added locally (not from upstream)

- `LICENSE` — copied verbatim from the umbrella repo root (upstream has none
  inside the skill directory).
- `PROVENANCE.md` — this file.

## Ownership model

This is a **vendored-and-owned** copy, not a tracked fork:

- Copied once from the commit above (2026-07-13); we now **own it locally**.
- Edit freely — there is no manifest to keep in sync and no "don't hand-edit" rule.
- Cutting the cord is deliberate: it keeps the framework fully self-contained
  (no ongoing upstream dependency). The trade-off is that the model-specific
  guides (Claude / GPT / Gemini prompting) can rot as those models version.

## Checking for upstream changes (optional, on demand)

If you want to know whether fresher content exists upstream — e.g. before
relying on a model-specific guide — run the probe:

```bash
python3 scripts/check_vendored_drift.py
```

It fetches the upstream skill and diffs it against our copy. If they differ and
you want the newer content, copy it in manually and update the "Pinned commit"
row above. Needs git + network; skips gracefully if offline. Informational only —
the framework never requires it.


## Role in this framework

`prompt-engineering` is an **advisory, progressive-disclosure** skill — meta-skills
(`designer`, `validator`, `enhancer`) consult its references on demand (e.g. the
model-specific guides, the 8-dimension audit checklist, the failure taxonomy); it is
**not** a hard dependency. Designed harnesses may also delegate to it at runtime.

Unlike `skill-creator` (a hard dependency the pipeline cannot run without), the
framework still functions if this skill is absent — it just produces less-optimized
prompts.
