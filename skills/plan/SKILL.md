---
name: plan
description: Plan work bigger than an afternoon - align, then write the PRD, kept in ~/.claude/plans/<project>/<topic>/. Use when the user says "let's plan", "make a plan", "how would we do X" or "where are we with X", or wants to pick a plan back up. Ends with an approved PRD.
---

# Planning work

A plan is worth writing when the work outlives one sitting: several tasks,
decisions somebody will ask about later, or questions only another person can
answer. A one-file fix does not need one - say what you are about to do and do
it.

A conversation gets compacted and sessions end, so later work knows only what
is written down. What makes the folder worth keeping is the **PRD, the
decisions and the task briefs**.

## Where a plan lives

```
~/.claude/plans/<project>/<topic>/
├── prd.md                     what we build and how, as agreed - including what is out of scope and later
├── decisions.md               every decision, short, and the questions still open
├── plan.md                    progress: the status, and the tasks (made by task-create)
├── handoff.md                 what the last build session left for the next one
├── tasks/
│   ├── 01-<name>.md           one brief per task: everything a fresh session needs
│   └── 02-<name>.md
├── questions-for-<who>.md     questions someone outside the session has to answer
└── anything else              spec extracts, scratch scripts, screenshots, notes
```

`<project>` is the working directory's name, `<topic>` is short and kebab-case
(`invoices`, `member-login`). The folder is for everything about that topic,
so research that took an hour to gather is still there next month.

Create the folder as soon as there is something to put in it.

**Plans never go in the repository.** A plan in a branch disappears when the
branch merges, and it is not the project's documentation.

## The phases

| Phase | Skill | What comes out | Ends when |
|---|---|---|---|
| 1. Align | `align` | answers, and the first entries in `decisions.md` | the user says we are aligned |
| 2. PRD | this one | `prd.md` | the user approves the PRD |
| 3. Tasks | `task-create` | `plan.md` and the briefs | the user approves the plan |
| 4. Build | `execute-tasks`, or `execute-tasks-tdd` when the project has tests | the code, one slice at a time | the last task is done |

**Never move to the next phase on your own.** Each one ends with the user saying
so.

**No code before phase 4.** Code written before we agree on what it does has to
be found and unpicked later, and that costs more than waiting.

Do everything in this session, with no subagents.

## Phase 1 - Align

Use the `align` skill. Its decisions go in this folder's `decisions.md`, and
its questions document in `questions-for-<who>.md`.

## Phase 2 - The PRD

Once the user says we are aligned, write `prd.md` from `assets/prd-template.md`.
It is the agreement in one place: what we build, for whom, and how. Phase 3
cuts the tasks from it, so every behaviour that will be built is in it.

Write it from the conversation and `decisions.md`; do not read the code again.
Keep it short and plain, and skip a section that has nothing to say. Point at
decisions by number ("decision 4") and at the repository's docs by path instead
of repeating them. If writing it raises a new question, ask it - phase 1 is not
over just because the PRD has started.

Do not print the PRD in the conversation. Tell the user the file is ready, in a
few lines: the behaviours, and anything you decided while writing it. Changes
go into the PRD and `decisions.md` as edits, not rewrites. When the user
approves, say the next step is `task-create` and stop.

## Picking a plan back up

When the user asks where something stands, read the folder first: `plan.md`
and `handoff.md` if they exist, otherwise `decisions.md` and `prd.md`. Answer from that. Then
check it is still true - a branch may have merged, a question may have been
answered - and fix the files before reporting. A plan nobody trusts is worse
than no plan, and it decays quietly.

Which phase it is in follows from what exists: no `prd.md` means phase 1 or 2,
a PRD and no `plan.md` means phase 3, a `plan.md` means phase 3 or 4. If the
work is still in phase 1 or 2, carry on there; do not jump ahead to tasks
because the user asked for the next one. If a blocking question is open, say so
and offer to chase it: point to the questions document, or update it.

When the work is finished, say so in the status line of `plan.md`, and move any
open questions somewhere they will be seen. Leave the folder; it is the record
of why the code looks the way it does.
