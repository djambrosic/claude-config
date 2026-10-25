---
name: execute-tasks-tdd
description: Build one task from a plan's brief test-first - red, green, refactor, with every test seen failing for the right reason before the code that passes it. Use it instead of execute-tasks when the project has a test setup and the user wants test-first, or says "TDD", "test first", "red green". Not for projects without tests; use execute-tasks there.
---

# Build a task, test first

Follow the `execute-tasks` skill for everything around the build: starting,
doing this task only, reporting, commits, and keeping the plan current. This
skill replaces its "Build" step with the loop below. If the project has no test
setup, stop and use `execute-tasks`.

## Red, green, refactor

Every line of production code is written because a failing test asked for it.
A test you have not watched fail proves nothing - it may pass whatever the
code does, and a project can collect a thousand of those without anyone
noticing.

For each behaviour in the brief's "Tests, in order":

1. **Red.** Write one test for the next behaviour. The first test of a slice
   is the outermost one - the "Try it" behaviour, through the API, screen or
   command, the way a user would reach it. Run it and read the failure. It
   must fail **for the reason you expect**: the behaviour is missing, so the
   answer is wrong. A failure from a typo, a missing import or a broken
   fixture is not red yet - fix that and run again. If the test passes before
   you have written anything, either the behaviour already exists or the test
   checks nothing; find out which before going on.
2. **Green.** Write the least code that makes it pass. No extra field, no
   "while I am here", no case the test does not ask for - that is the next
   test's job. Run it and see it pass.
3. **Refactor.** With everything green, tidy up: names, duplication, fitting
   the surrounding code. Run the tests after each change. A refactor adds no
   behaviour; if you want new behaviour, that is a new red.

Then the next behaviour - each rule, refusal and edge case gets its own red.
Lower-level tests come in where a piece of logic has many cases that are
cheaper to pin down directly than through the outer test, such as a
calculation. They are red first too.

Run tests quietly and look only at the result: the failing test's name and
message when red, the counts when green.

## What makes a test worth having

- **It fails when the behaviour breaks.** That is the whole point, and having
  watched it fail is how you know.
- **It checks what happened, not how.** The response, what was stored, what
  was sent - not which methods were called in which order. A test tied to the
  inside breaks on every refactor and still misses real bugs.
- **One behaviour per test, named in plain words**:
  `testReservationIsRefusedWhenMemberOwesAFine`, not `testReserve2`.
- **Fake only the edges** - outside services, the clock, the mailer. Faking
  your own code to "isolate" it tests the fake.

## Rules

- **Never change a test to make it pass.** If the test was wrong, say so to the
  user and why, then fix it.
- **A bug is fixed by first writing the test that shows it**, and seeing it
  fail.
- **Existing tests are not proof.** Where the code a slice touches has tests
  you do not trust, do not lean on them - the slice's own tests are the proof.
  A test you notice cannot fail goes into the report; it is not swept up in
  passing.

## In the report

Add to the `execute-tasks` report: each test written, with the one-line failure
it showed when it was red.
