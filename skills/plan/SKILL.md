---
name: plan
description: Start a plan for a piece of work - align on what to build, then write the PRD, and keep both in ~/.claude/plans/<project>/<topic>/. Use it whenever the user says "let's plan", "make a plan", "how would we do X", "where are we with X", or asks to pick a plan back up, and for anything bigger than an afternoon, because a plan that lives in the conversation dies with it. It ends with an approved PRD; the task-create skill cuts the tasks and the execute-tasks skills build them.
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
It is the agreement in one place: what we build, for whom, and how. The task
cutting in phase 3 works from it, so every behaviour that will be built is in
it.

- **Problem** - who has it and why it matters, in a short paragraph.
- **What someone can do** - numbered behaviours, each phrased as "A member
  can reserve a book", with its rules and refusals underneath. These become
  the slices in phase 3, so each one should be something you could try.
- **Rules across the story** - what holds everywhere in it: a word the whole
  feature uses, a status model, how money is rounded.
- **How it is built** - the approach at the level of design: what is stored,
  which endpoints or screens, what is reused or changed. Not code.
- **Out of scope** - what someone will reasonably assume is included and is
  not. Saying so here is cheaper than an argument later.
- **Later** - real, but not this story. Nothing here gets a task.
- **How we know it works** - per behaviour, what proves it.

Keep it short and plain. It points at decisions by number ("decision 4")
instead of repeating their reasoning. If writing it raises a new question,
ask it - phase 1 is not over just because the PRD has started.

Show it to the user and wait. Changes go into the PRD and `decisions.md`.
When the user approves, say the next step is `task-create` and stop.

## Picking a plan back up

When the user asks where something stands, read the folder first: `plan.md`
if it exists, otherwise `decisions.md` and `prd.md`. Answer from that. Then
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
