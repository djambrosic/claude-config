# Task NN - <what someone can do>

Plan: `~/.claude/plans/<project>/<topic>/plan.md` - Milestone N - <name>
Estimate: ~120k - where the figure comes from, in one line
Waiting on: nothing (or: question 2 - who owes it)
Starts from: filled in when the task begins - the title of the commit it is built on

The name is what someone can do when this task is done ("A member reserves a
book"), never a layer or a class.

## Goal

What someone can do when this task is done, and why it is needed. A few
sentences in plain language, with the business context someone joining the
project tomorrow would be missing.

## Summary

What to build, through every layer this behaviour needs - and only the
storage, fields and code it actually uses. A short paragraph or a few bullets,
enough that a fresh session can start without the conversation that produced
this plan.

## Decisions that shape it

- **Decision 2** - what was decided, in a line, so nobody has to open the
  decisions file.
- **Decision 5** - ...

## Technical notes

Everything that helps with this task and only this task: the approach when it
is not obvious, the traps, the edge cases, what went wrong nearby before. The
rules across the story that this task needs, copied from the PRD.

## Where to start

- `path/to/the/code/it/changes` - one or two files, no more

## Try it

How to see this slice working, and what should happen. For an API:

```
POST /reservations
{ "book": 42 }

→ 201, the reservation, expiring in three days
```

For a screen, the steps and what appears; for a command, the command and its
output.

## Tests, in order

Only when the project has a test setup; otherwise leave this section out and
say in "Try it" how the slice is checked by hand.

Written one at a time, each seen failing before the code that passes it.

1. The "Try it" behaviour, from the outside - e.g. a member reserves an
   available book and gets the reservation back.
2. The next rule - e.g. reserving a book that is already reserved is refused.
3. ...

## Not in this task

What belongs to the next task, so this session does not wander into it.

## Notes from building

Filled in while working: each test with the one-line failure it showed when
red, what "Try it" returned, what turned out differently, what was left, the
real token figure against the estimate.
