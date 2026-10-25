---
name: execute-tasks
description: Build one task from a plan's brief, in this session - read the brief, do that task only, finish on "Try it", run the project's existing checks, report, and tick the task in plan.md. Use it when the user says "next task", "build task 03", "continue", or "let's build it", and for projects without a test setup (legacy code); when the project has tests and the user wants test-first, use execute-tasks-tdd instead.
---

# Build a task

Works from a brief in `~/.claude/plans/<project>/<topic>/tasks/` (see the `plan`
and `task-create` skills). The user leads and reviews in this session. Do the
work yourself, with no subagents.

## Start

Read `plan.md`, then the brief and the files it says to read. Nothing else
up front: everything read early is carried through every turn after it.

Check nothing has changed since the brief was written - a question answered,
an earlier task built differently - and fix the brief first. Write the commit
the task starts from into the brief (`Starts from:` - the title of the last
commit, `git log -1 --format=%s`), so a later review can be given just this
task's changes. **Never a commit hash, here or anywhere in the plan:**
branches get rebased and squashed, and every hash changes.

Mark the task `[~]` in `plan.md`.

## Build

- **Do this task only.** If you find something that belongs to another task,
  write it into that task's brief instead of doing it. That includes the
  column or field "we will need anyway" - it goes in with the slice that uses
  it.
- **Follow the surrounding code.** Names, structure and comments match what is
  already there. Read the project's rules before writing.
- **Small steps, checked as you go.** After each step run whatever quick
  check the project has: the linter, the type checker, the affected tests.
- **No test setup?** Do not add one as part of the task. Say in the report
  what you could not check automatically.

## Finish on "Try it"

Run the project's full check (tests, linters, static analysis - whatever it
has), then try the slice the way the brief says: send the request, open the
screen, run the command, and look at what happens.

Report quietly: pass or fail and the counts. On a failure, the error and the
reason, not the output that led up to it.

## Report

Write in the brief's "Notes from building" and tell the user:

- what "Try it" returned;
- what you checked and how, and what you could not check;
- anything that went differently from the brief;
- the real token figure against the estimate, if the user tells you it from
  `/context`; otherwise say roughly whether the session had room left.

**Say plainly when something breaks**, with the output. A task that half works
is more useful said out loud than smoothed over.

## Commits and databases

- **Nothing is committed until the user asks.** They review the code first.
  Pushing, pull requests, tags and squashing are always asked for.
- **Databases:** follow the project's and the user's rules on what may be
  written without asking. When in doubt, ask, and say exactly what you intend
  to run.

## If the task is running over

Stop at a point where everything still works, write in the brief what is done
and what is left, and tell the user. Splitting a task halfway is fine. Running
out of room with the work broken is not.

## Keep the plan current

The next session only knows what the files say, so updating the plan is part of
finishing the task:

- Tick the task in `plan.md`, with the commit's title if there is one.
- Add decisions to `decisions.md` as they are made.
- If the task turned out differently from its brief, write what changed into
  the briefs of the tasks that follow, and into the PRD if the behaviour
  changed.
- If a later task is bigger or smaller than estimated, fix its estimate now.
- Add the real figure next to the estimate (`~110k, real ~170k`) and a sentence
  on why in "Notes from building". When estimates keep missing in the same
  direction, say so, so the figures in `task-create` can be corrected.
- Correct the `**Status:**` line.

When the task (or milestone) is done, show what changed with a short
explanation of how it works, name the next task, and stop. Do not start a
review or anything else on your own.
