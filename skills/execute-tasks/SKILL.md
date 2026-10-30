---
name: execute-tasks
description: Build one task from a plan's brief in this session - that task only, finish on "Try it", run the project's checks, report and update the plan. Use when the user says "next task", "build task 03", "continue" or "let's build it", for projects without tests; with tests and test-first, use execute-tasks-tdd.
---

# Build a task

Works from a brief in `~/.claude/plans/<project>/<topic>/tasks/` (see the
`task-create` skill). Do the work yourself in this session, with no subagents.

- **Commit, push or open a pull request only when the user asks**, each time.
  They review the code first.
- **Databases:** ask before any write - data, schema, migrations, seeds - and
  say exactly what you will run.
- **Run checks quietly.** Report pass or fail with counts; on a failure, the
  error and why.

## Start

Read `plan.md`, `handoff.md` if it exists, the brief and the files it names.
Nothing else up front:
everything read early is carried through every turn after it.

If something changed since the brief was written - a question answered, an
earlier task built differently - fix the brief first. Fill in `Starts from:`
with `git log -1 --format=%s`. **Never a commit hash** in the plan: rebases
change it.

Mark the task `[~]` in `plan.md`.

## Build

- **This task only.** Something that belongs to another task, including the
  field "we will need anyway", goes into that task's brief.
- **Match the surrounding code**: names, structure, comments.
- **Small steps.** After each one run the quickest check the project has: the
  linter, the type checker, the affected tests.
- **No test setup?** Do not add one. Say in the report what you could not
  check.

If the task is running over, stop where everything still works, write in the
brief what is done and what is left, write `handoff.md` (see Finish), and tell
the user.

## Finish

1. Run the project's full check, then try the slice the way "Try it" says and
   look at what happens.
2. Write "Notes from building" in the brief: what "Try it" returned, what
   turned out differently, what was left, and the real token figure if the
   user gives it from `/context`.
3. Update the plan:
   - In `plan.md`, mark the task and add the real figure next to the estimate
     (`~110k, real ~170k`), plus the commit title if there is one. Correct the
     `**Status:**` line.
   - New decisions go in `decisions.md`.
   - If the task turned out differently, update the later briefs, their
     estimates, and the PRD if the behaviour changed.
   - When estimates keep missing in the same direction, say so.
4. Overwrite `handoff.md` in the plan folder for the next session. It holds
   only what no other file says, in 15 lines or fewer - point to the PRD,
   briefs and decisions by path or number instead of repeating them:
   - **State** - branch, and what is committed or still in the working tree.
   - **Environment** - anything the next session must know to run things: a
     migration not yet run, a service to restart, stale test data.
   - **Watch out** - what you learned that matters for the next task and is
     not in its brief.
   - **Next** - the next task's brief path.
5. Report: what "Try it" returned, what you checked and could not check, what
   went differently from the brief, how the change works in short, and the
   next task. **Say plainly when something breaks**, with the error.

Then stop. Do not start a review or the next task on your own.
