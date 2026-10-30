---
name: task-create
description: Cut an approved PRD into vertical-slice tasks, each one a behaviour that ends in something you can try, and write plan.md plus one standalone brief per task. Use when the user says "break this down", "make the tasks", "cut it into tasks" or "create the plan" once a PRD exists.
---

# Cut the work into tasks

Input: the approved `prd.md` in `~/.claude/plans/<project>/<topic>/`, with no
blocking question open in `decisions.md`. With no PRD, cut small, clear work
from what the user said; otherwise use `align` first.

Output: `plan.md` from `assets/plan-template.md`, and `tasks/NN-<name>.md` per
task from `assets/task-brief-template.md`.

## Slices

**A task is one behaviour, end to end, that you can try when it is done.** It
holds every layer that behaviour needs and nothing it does not use. Never cut
by layer ("the entities", "the tests for X").

- Name it after what someone can do: "A member reserves a book".
- The first slice is the thinnest path through every layer; later slices add a
  field, a filter, an action or a rule.
- Shared infrastructure, new columns and docs go in the first slice that uses
  them.
- A refusal can be its own slice when the happy path is already big.

## Tests

If the project has tests (a runner, a `tests/` folder, a test command), briefs
get "Tests, in order" and are built with `execute-tasks-tdd`. If not, drop that
section, make "Try it" checkable by hand, and use `execute-tasks`. Say which in
`plan.md`.

## Size

Aim for 100-150k tokens per task. Estimate: 30k to start a session, ~10
tokens per line read, ~25 per line written (fixes included), 2-5k per test or
lint run, 5-15k searching, then +20% for review. Over 150k, make the slice
thinner; under 70k, merge it with a neighbour. Round up.

Past about five tasks, group them into milestones: a capability someone can
use, one to three tasks, with the total in the header.

## plan.md

Marks: `[ ]` to do, `[~]` in progress (or built, waiting for review), `[x]`
built and verified, `[!]` blocked with the reason. Merging to main is the
`**Merged:**` line. Decisions and out-of-scope items are never tasks.

## Briefs

Someone with the repository but not the plan must be able to read the brief
and start building.

- Write each decision out in a line, with its number.
- Name one or two files to start from, no more.
- Never defer a decision to the build; answer it now.
- A rule for this task goes in its Technical notes; a rule for the whole story
  goes in the PRD and is copied into each brief that needs it; a rule for the
  whole project goes in the repository's rules, with the first task that needs
  it.

## Show it

Show the tasks with estimates, the number of sessions, and the open questions
with what waits on each. When approved, name the next skill and stop.
