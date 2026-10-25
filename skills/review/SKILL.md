---
name: review
description: Review a pull request, a branch, or work in progress for whether it does what was asked, follows the repository's own rules, and is free of defects - done right here in the session the user calls it in, no subagent - then report findings ranked by severity without posting anything. Runs only when the user asks. It replaces the built-in code-review skill - use it, not that one, whenever the user says "code review", "review this PR", "review branch X", "can you check my colleague's changes", "second pair of eyes", or asks whether something is ready to merge. Use it too before posting any review comment to GitHub, because the rules about what may be posted live here.
---

# Reviewing changes

The job is to find what will hurt: a change that does not do what was asked,
rules the repository has written down and this change breaks, defects, and
claims that are not true. Everything else is noise that makes the real findings
harder to see.

This file has two parts. **Part 1** works out what to review and against what.
**Part 2** is the review itself. Both happen in this session.

# Part 1 - Starting a review

## In this session, no subagent

**Do the review yourself, here.** The user calls the reviewer themselves, in
the session they choose for it, so never start an agent or a fork to do it.

If this session wrote the code being reviewed, say so at the top of the
report: you know why every line is there, and that is exactly how a reviewer
lets a mistake through. Judge the code against what was asked and the rules,
not against what you remember meaning.

Reviews run **only when the user asks.** Do not start one on your own when a
task or a milestone ends: they look at the code first and then say what comes
next. This skill is for every review they ask for: a milestone's changes, a
pull request, a branch, someone else's changes.

## 1. Work out what to review

The changes made for the work - **committed or not**:

- **A pull request:** its number; read the diff from GitHub.
- **A branch, or work on this machine:** everything changed since the branch
  left `main`, plus whatever is not committed yet, plus new files git does not
  track yet. The base is `git merge-base origin/main HEAD`.
- **One task of a plan, on a branch that holds earlier tasks:** if `plan.md`
  records where this task started (the last commit of the task before it), use
  that commit as the base instead, and say the earlier changes belong to
  earlier tasks. Otherwise review the whole branch and say so.

## 2. Work out what was asked

The code is judged against the request, so the request has to be the request -
not a description of what got built.

- **A task from a plan:** its brief, `tasks/NN-<name>.md`, and `plan.md` for
  the decisions. Nothing else is needed.
- **Someone else's pull request:** its description, plus anything the user has
  said about what it is for, in their words.
- **No plan:** write a short description of what was asked - the goal, what
  should exist when it is done, and anything deliberately left out. Write it
  from the original request (the user's words, the ticket, the issue), not
  from the code. **Show it to the user and wait for them to confirm it**
  before reviewing. A wrong description makes the whole review measure the
  wrong thing.

**A reason the code depends on belongs in the plan's decisions or the code
itself.** If it lives only in a conversation, the code does not say it - and
that is a useful finding.

## 3. After the report

The user says which findings to fix. A second look after the fixes is another
review they ask for.

# Part 2 - Doing the review

Two habits carry most of the weight:

- **Verify before saying it.** A finding is worth reporting when you can name the
  input and the damage. Read the surrounding code, run the query, fetch the
  document. What you cannot demonstrate goes in "worth discussing", clearly
  separated, so the author can trust the rest.
- **Change nothing, post nothing.** Reviews go out under the user's name. Give
  them the report, and fix only what they then ask for.

Write in English unless the user says otherwise - the report, the comments,
all of it.

## 1. Find out what you are reviewing

For a pull request:

```bash
gh pr view <number> --json title,body,commits,reviews,statusCheckRollup,baseRefName
gh pr diff <number>
```

`gh` may be missing or unauthenticated. Fall back to git without ceremony:
`git fetch origin && git diff origin/main...origin/<branch>`.

For a branch or work on this machine, review everything from the base you were
given to the working tree as it is now:

```bash
git diff <base>                       # committed and uncommitted changes together
git status --short                    # new files git does not track yet - read those too
```

Three things are worth knowing before reading a line of the diff, because each
one changes what your findings mean:

- **Is CI green?** A failing build makes half a review redundant.
- **Is the branch current with `main`?** `git merge-base --is-ancestor origin/main <branch>`.
  Behind means the diff is partly other people's work, and it means a rebase is
  coming that may change what you are reading.
- **Has anyone reviewed it already?** Repeating a comment somebody already left
  reads as though you did not look.

## 2. Read what was asked

Read the task brief, the confirmed description, or the PR description - whichever
you were given. For a plan task, also read the decisions in `plan.md` the brief
points to. This is what the change is measured against.

## 3. Load the rules the repository wrote for itself

Read `CLAUDE.md` and the rules it points to - often a folder such as
`.aiassistant/rules/` or `.claude/rules/`, with a core file plus one per area.
Read the core, and the area files covering what the change touches. It is not
background reading: most of it was written after somebody made that exact
mistake, so it is a list of the defects this codebase actually produces. A
change that breaks one of those rules is a finding, and the rule is the
evidence.

If the repository keeps module docs - a `docs/` folder, usually indexed from
the rules file - read the ones for the modules the change touches. They say
how that part is meant to work, which is what a change is measured against.

Also read the project's review notes, if it has any: a file its rules name for
known traps, or `~/.claude/plans/<project>/review-notes.md`. They list the
defects worth checking every time in that codebase.

If the project has no rules and no docs, say so at the top of the report and
review against general defects only. Do not invent rules for it.

## 4. Does it do what was asked?

Before looking for defects, check the change against the request:

- **Is everything there?** Go through the goal and "done when" one by one. A
  part that is missing is a finding, however good the rest is.
- **Does it do it the way it was decided?** A brief or plan decision says
  "written in the same transaction"; the code writes it afterwards. That is a
  finding.
- **Is there more than was asked?** Changes outside the task - a refactor
  nobody asked for, the next task started early, files touched for no reason
  the request explains - are findings too. Check them against "not in this
  task" when there is one.
- **Does the proof exist?** If "done when" names a test, the test should be in
  the change and should actually test that.

## 5. Read the diff in passes

One pass per question keeps you from skimming everything once and catching
nothing:

- **Correctness.** What input makes this wrong? Nulls, empty collections,
  concurrent writes, a user with no permissions, a record in the other
  organization.
- **Contracts.** Does it match how the rest of the codebase does this? A new
  endpoint that invents its own error shape is a defect even when it works.
- **Data.** Migrations, seeds and fixtures deserve their own pass. They are the
  changes that cannot be undone by deploying yesterday's code.
- **Tests.** Not "are there tests" but: would they fail if the behaviour broke?
  A test that asserts on one row proves nothing about a filter.
- **Its own documentation.** If the repository keeps rules, module docs or a
  README that this change makes wrong, that is a finding too - and a change
  that alters how a module works without touching its doc is one, because the
  doc will now be believed and be wrong.

Then ask what the change means for work in flight: another branch adding
entities, a sweep test that counts things, a migration that has to run in a
certain order. Say which branch has to move, not just that they clash.

## 6. Check the claims

A pull request says things - "these values are approved", "this matches the
specification", "both copies agree". Those are the claims most worth checking,
because nobody else will.

- Two copies of the same data: compare them field by field with a script rather
  than by eye.
- A claim about the specification: fetch the specification and grep it. If the
  project's review notes say where it is and how to read it, follow them.
- A claim about behaviour: run it.

## 7. Run the tests when the change deserves it

Worth doing when the change touches logic rather than only text, and when CI is
red or absent.

Use the test command from the project's rules.

For a pull request or a pushed branch, use a separate worktree (in the
scratchpad) so nothing the user has checked out is disturbed:

```bash
git worktree add <scratchpad>/review-<branch> origin/<branch>
# run the project's tests there
git worktree remove <scratchpad>/review-<branch>
```

For work on this machine with uncommitted changes, a worktree would not contain
them, so run the tests in the working copy as it is. Do not stash, check out or
reset anything to do it.

If tests need a database at the right schema and it is stale, **do not reset
it** - it is a write, and it is not yours to decide. Say in the report what you
could not run and why, rather than guessing at it.

## 8. Report

Rank by what it costs to get wrong, not by where it appears in the diff. Say
what breaks and why, once, without repeating the code back.

```markdown
## Does it do what was asked
[One line per part of the goal / "done when": done, missing, or done
differently - and anything changed that was not asked for.]

## Should change
**1. [One sentence naming the defect].** [Where it is, what input triggers it,
what happens.] **Fix:** [what would resolve it].

## Worth discussing
[Design questions and things you could not verify - kept apart from the
defects so the author knows which is which.]

## Minor
[One line each. Naming, a missing test, a stale comment.]

## What I could not check
[Tests not run, claims not verifiable, and why.]

## What's good
[Briefly, and only what is true. It tells the author which parts you actually
read.]
```

Two things that make a review land: give each finding a concrete failure
("a user with a 180-character email and a 120-character name makes the insert
fail, and the change rolls back with it"), and say plainly when you checked
something and found it correct. A review that is only complaints reads as
though the reviewer went looking for them.

# Posting

Only when the user asks. Read `references/github.md` first - GitHub's rules
about pending reviews have sharp edges that cost a round of confusion each
time. Leave the review pending for the user to submit. They decide what goes out
under their name.
