---
name: execute-tasks-tdd
description: Build one task from a plan's brief test-first - red, green, refactor, with every test seen failing for the right reason first. Use instead of execute-tasks when the project has tests and the user says "TDD", "test first" or "red green".
---

# Build a task, test first

Follow `execute-tasks` for everything except its "Build" step, which this loop
replaces. If the project has no test setup, use `execute-tasks` instead.

## Red, green, refactor

For each behaviour in the brief's "Tests, in order":

1. **Red.** Write one test and run it. It must fail **for the expected
   reason**: the behaviour is missing. A typo, missing import or broken fixture
   is not red yet; fix it and run again. If it passes before you wrote any code,
   find out whether the behaviour exists or the test checks nothing. The first
   test of a slice is the outermost: the "Try it" behaviour, the way a user
   reaches it.
2. **Green.** Write the least code that passes it - nothing the test does not
   ask for.
3. **Refactor.** With everything green, tidy names, duplication and fit with
   the surrounding code. Run the tests after each change. No new behaviour.

Run tests quietly: the failing test's name and message when red, the counts
when green.

Each rule, refusal and edge case gets its own red. Use lower-level tests where
logic has many cases that are cheaper to cover directly, such as a
calculation.

## Tests

- Check what happened - the response, what was stored, what was sent - not
  which methods were called.
- Fake only the edges: outside services, the clock, the mailer.
- One behaviour per test, named in plain words:
  `testReservationIsRefusedWhenMemberOwesAFine`.

## Rules

- **Never change a test to make it pass.** If the test was wrong, tell the user
  why, then fix it.
- **A bug is fixed by first writing the test that shows it** failing.
- **Existing tests are not proof.** The slice's own tests are. A test you
  notice cannot fail goes in the report.

## Report

Add to the `execute-tasks` report each test with the one-line failure it
showed when red.
