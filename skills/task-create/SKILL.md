---
name: task-create
description: Cut an approved PRD into vertical-slice tasks - each one a behaviour built through every layer that ends in something you can try - size them, write plan.md as a markdown checklist and one standalone brief per task in the plan folder. Use it when the user says "break this down", "make the tasks", "cut it into tasks", "create the plan" once a PRD exists, or asks for a task list for work that is already clear.
---

# Cut the work into tasks

Works from `prd.md` in `~/.claude/plans/<project>/<topic>/` (see the `plan`
skill for the folder). Only once the PRD is approved and no blocking question
in `decisions.md` is open. If there is no PRD and the work is small and clear,
write the tasks straight from what the user said; if it is not clear, use
`align` first.

Output: `plan.md` from `assets/plan-template.md`, and one brief per task in
`tasks/NN-<name>.md` from `assets/task-brief-template.md`.

## Every task is a vertical slice

**A task delivers one behaviour, end to end, and ends with something you can
run.** It holds every layer that behaviour needs - storage, migration, the
API or screen, validation, the logic, permissions, the doc change and the
tests - and nothing the behaviour does not use. When it is done, someone can
try it and, where the project has tests, a test proves the answer.

Never cut by layer. "All the entities", "the schemas", "the repositories",
"the tests for X" are not tasks. A task like that cannot be tried when it is
done, so the user reviews code they cannot see working, and the mistakes in it
surface three tasks later, when something finally calls it.

How to cut:

- **Name the task after what someone can do**, in user terms: "A member
  reserves a book", "A librarian sees which loans are overdue". If the only
  honest name is a class or a layer, it is not a slice.
- **The first slice is the thinnest path through every layer**: one
  endpoint or screen, the two or three fields it cannot do without, the
  permission, one test. Later slices widen it - a field, a filter, an action,
  a rule - each one again testable on its own.
- **Build only what this slice uses.** Storage gets the columns this
  behaviour reads or writes, the response the fields it shows. The next slice
  adds its own. A column or a field nobody calls yet is a guess.
- **Shared infrastructure is built inside the first slice that needs it**,
  not ahead of it as its own task. A new building block with no caller is
  designed blind; with one caller it is designed for a real case.
- **The happy path and its refusals can be separate slices** when one is too
  big: "a member reserves a book" first, then "a reservation is refused when
  the member owes a fine". Each is still something to try.
- **The docs change in the same slice** as the behaviour they describe.

Each brief names how to try the slice - for an API the request (method, path,
body) and the answer it should get; for a screen the steps and what appears;
for a command the command and its output.

## Does the project have tests?

Look before writing the briefs: a test runner configured, a `tests/` folder,
a test command in the project's rules. If yes, each brief gets a "Tests, in
order" section. If no, leave the section out, and make "Try it" precise enough
to check by hand. Say which in `plan.md`'s opening paragraph, because it
decides which execute skill builds the tasks: `execute-tasks-tdd` with tests,
`execute-tasks` without.

## Size

**One task is about 150k tokens of work.** The size keeps each piece small
enough to review in one sitting, and the estimate shows when the work is
bigger than it looks.

Estimate each task from what it actually involves. These are starting
figures; adjust them when the real numbers say otherwise:

| What the session does | Rough cost |
|---|---|
| Starting up: system prompt, CLAUDE.md, repository rules, skill, `plan.md`, the brief | 25-35k, every session |
| Reading existing code | about 10 tokens per line. A 400-line file is about 4k, and files usually get read more than once |
| Writing new code and tests | about 10 tokens per line written, then times 2-3 for edits and fixes |
| Running tests, linters, commands | 2-5k per run. Test-first runs the tests after every step, so plan for many |
| Searching and looking around | 5-15k, more in an unfamiliar area |
| Showing the work and fixing what the user points out | add 20% on top |

Write the total on the task line as `~120k`. Then check the size:

- **Over 150k** - make the slice thinner, never cut it into layers: fewer
  fields, one case of the rule, the happy path before the refusals. Both
  halves must still be something to try.
- **Under about 70k** - merge it with the neighbouring slice, so a session is
  not spent mostly on starting up. The merged task then has two things to try.
- **Aim for 100-150k.** Rounding up is better than down: a session that runs
  out of room halfway leaves the work in a worse state than one that finishes
  early.

## Milestones, only when the story is big

A small story is a flat list of tasks. When it grows past about five tasks,
group them into milestones. **A milestone is a capability someone can use,
made of slices** - "members can reserve books" - and the point where the user
stops to review. Cut them as small as that allows, usually one to three tasks.
Put each milestone's total in its header: `**Milestone 2 - Reservations**
(~380k, 3 tasks)`.

A milestone is not a branch or a pull request. Which branch the work goes on,
and when a pull request is opened, is the user's call.

## plan.md

`plan.md` holds the progress and nothing else:

```markdown
# Book reservations

**Status: building** - task 02 in progress.
**Merged: no**

One paragraph: what this is, which repository and branch it is on, and
whether the project has tests.
[PRD](prd.md) · [Decisions](decisions.md)

## Progress

**Milestone 1 - Reservations** (~250k, 2 tasks)
- [x] 01 A member reserves a book - ~110k, real ~130k - [brief](tasks/01-reserve-a-book.md) - "Reserve a book"
- [~] 02 A reservation is refused when the member owes a fine - ~140k - [brief](tasks/02-refuse-with-fine.md)

**Milestone 2 - The desk**
- [!] 03 A librarian sees which loans are overdue - ~130k - [brief](tasks/03-overdue-loans.md) - waits on question 2
```

Without milestones, the task lines go straight under `## Progress`.

Four marks: `[ ]` to do, `[~]` in progress, `[x]` done, `[!]` blocked with the
reason written after it. Each task line carries its number, its estimate and
a link to its brief; the number is the brief's filename prefix.

A task is ticked when it is **built**: verified, and committed when the user
asked for the commit. Built and waiting for review is `[~]`, with "built, in
the working tree" after it. Whether the work has reached the main branch is the
separate `**Merged:**` line, changed to `**Merged: yes** - #51` when the pull
request lands.

**Decisions are not tasks.** "Decide what is shared" never goes in the
progress list. It goes in `decisions.md`; the tasks it produces go in the
plan. Backlog and out-of-scope items are not tasks either - they live in the
PRD.

If the user wants to see the plan as a page, they ask for an artifact; build it
from `plan.md` then. Nothing renders it by default.

## The task brief

The brief is what the session that builds the task starts from. Whoever reads
it - the user, a fresh session, a colleague who has never seen the plan - must
understand from the brief alone what the task is for and how to build it:

- **Goal** - what someone can do when this task is done, and why it is needed,
  with the business context a newcomer is missing. Plain language.
- **Summary** - what to build, through every layer, and only what this slice
  uses.
- **Decisions that shape it** - each decision it rests on, written out in a
  line with its number. Never only "see decision 12".
- **Technical notes** - the approach when it is not obvious, the traps, edge
  cases, what went wrong nearby before.
- **Where to start** - the one or two files the change starts from. No long
  reading list: everything read early is carried through every turn after it.
- **Try it** - how to see the slice working, and what should happen.
- **Tests, in order** - when the project has tests: the behaviours to pin
  down, one line each, in the order to write them. The first is the "Try it"
  behaviour.
- **Not in this task** - what belongs to the next task, so the session does not
  wander into it.
- **Estimate** and **Waiting on** - the figure with a line on where it comes
  from, and any parked question.

The test: someone with the repository but not the plan reads the brief, and
can say the goal and start building. If it needs the conversation that
produced it, it is not finished.

**A brief never defers a decision.** "Decide while building", "check with the
user before this part" - each is an open question, and planning is where it
gets answered. Questions that surface while building each cost a stop, a
restart or a rework.

**Where a rule goes.** Sort what you learn by how far it reaches:

- **This task only** - into the brief, under Technical notes.
- **Every task in this story** - into the PRD's "Rules across the story".
  Copy the ones a task needs into its brief, because the builder reads the
  brief, not the PRD.
- **Every task in the project** - into the repository's own rules, as part of
  the first task that needs it, so it lands in the same pull request as the
  code.

## Show it before building

Show the user the tasks with their estimates and how many sessions that comes
to, and the open questions with what waits on each. Then wait for them to
approve or change it. Changes go into `plan.md` and the affected briefs. When
approved, the next step is `execute-tasks` (or `execute-tasks-tdd`); stop and
wait for the user to say go.
