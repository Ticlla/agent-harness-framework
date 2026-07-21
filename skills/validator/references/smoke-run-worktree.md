# Smoke-run in an isolated worktree

Run the orchestrator on the one picked item in a **throwaway** worktree of the §2 target repo. Nothing reaches a shared branch; the worktree is discarded regardless of outcome.

## Choose the isolation mechanism

Default to a **plain git worktree**. Use a domain-specific worktree skill **only when the design's §2/§13 names one** — the validator is a meta skill and must not assume any particular stack.

- **Otherwise (default)** → plain git worktree:
  ```bash
  # <target> = §2 target repo path; <base> = §2 branch
  git -C <target> worktree add /tmp/hv-<orchestrator>-<short> <base>
  ```
- **Design names a worktree skill** (e.g. `fusion-worktree` for a Nuxt target: deterministic dev-server port, recoverable slug, JSON handoff) → follow that skill's SKILL.md instead.

## Run

1. Operate **inside the worktree path** — every orchestrator action and every §7 gate runs there.
2. Run the orchestrator on the single picked item only (not the full worklist).
3. Honor the §7 authoring gotchas the designer recorded:
   - run from the location §7 specifies (repo root vs worktree),
   - set required env / baseURL (avoid connection-refused against a dead localhost),
   - use the real filter mechanism (flag vs env var; the wrapper may reject `--grep`),
   - beware test-runner ignore globs (`testIgnore: ['**/.worktrees/**']` → "No tests found" if you run from an ignored path).

## Hard limits

- **Never** `git push`, open a PR, or commit to a shared branch.
- A local throwaway commit inside the worktree is fine if a gate needs it; it dies with the worktree.

## Teardown (always)

```bash
git -C <target> worktree remove /tmp/hv-<orchestrator>-<short> --force
git -C <target> worktree prune
```

For `fusion-worktree`, follow its own teardown. Confirm the target repo working tree is clean afterward and record the worktree path (now removed) in the report.

If a run is interrupted before this teardown runs, the worktree leaks under `/tmp/hv-<orchestrator>-*`. Teardown here is the primary cleanup; the next validation's preflight sweep (`preflight-checklist.md` check 0) is the backstop that clears orphans scoped to the orchestrator.
