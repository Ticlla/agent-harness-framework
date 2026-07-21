# Pick the worklist item(s)

Validation runs the orchestrator on **one** item by default — a representative smoke test, not the full batch. **Migration / batch-processing** domains run a **two-item** smoke (see below) so the batch loop is exercised at least once.

## Source of the worklist

Use the **deterministic §3 selector** the design already recorded (tag, header, directory convention, manifest, suite file). Do **not** invent a selection or ask the user to name an item if the selector is deterministic — enumerate by the selector and pick from that set.

## Which item to pick

Prefer, in order:

1. **Canonical / simplest** — the item that exercises the orchestrator's main path with the fewest moving parts (smallest fixture, fewest assertions, no exotic dependencies). A green run here proves the happy path end-to-end.
2. **Representative of the dominant sub-type** — if the worklist is heterogeneous, pick the most common shape, not an edge case.

Avoid: the largest item, known-flaky items, or items with unmet external dependencies — those test the environment, not the harness.

## Batch domains → two-item smoke

When §1 domain is **migration** or **batch-processing**, a single item never exercises the control logic that most often breaks: the `More work?` loop, cross-item dedup / skip-already-done, and clean termination after the last item. For these domains, pick **two** items in the same worktree run:

1. the canonical item (above), then
2. a second item of the dominant shape — ideally one that should be **skipped** if the worklist already contains prior work (to exercise dedup), else simply the next item.

Run the orchestrator across **both** in one pass and confirm: it advances past item 1, applies the skip/dedup rule on item 2 if applicable, and **terminates** instead of looping. This is still a smoke (2 items), not a full batch — record that limit in the report.

For all other domains, one item is enough; do not inflate the run.

## Record in the report

- The item id / path.
- The selector it came from (§3).
- One line on **why** it's representative (canonical / dominant shape).

## Ambiguity

If the §3 selector is ambiguous (e.g. an inferred mapping flagged for human confirmation), **ask the operator** which item before running — do not silently pick a reading. This mirrors the designer's §3/§8 human-confirmation flag.
