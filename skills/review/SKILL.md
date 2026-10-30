---
name: review
description: Review a pull request, branch or work in progress against what was asked, the repository's own rules and defects, in this session, and report findings ranked by severity without posting. Use it instead of the built-in code-review skill whenever the user asks for a code review, a PR review or whether something is ready to merge, and before posting any review comment to GitHub.
---

# Review changes

Find what will hurt: the change does not do what was asked, breaks a rule the
repository wrote down, has a defect, or claims something untrue. Leave out the
rest.

- Review yourself, in this session, with no subagent, and only when the user
  asks.
- Change nothing and post nothing. The user decides what to fix and what goes
  out under their name.
- If this session wrote the code, say so at the top of the report, and judge
  it against the request, not what you remember meaning.
- Write in English unless the user says otherwise.

## 1. What to review

Committed and uncommitted changes together:

- **Pull request:** `gh pr view <n> --json title,body,reviews,statusCheckRollup,baseRefName`
  and `gh pr diff <n>`. Without `gh`: `git fetch origin && git diff origin/main...origin/<branch>`.
- **Branch or local work:** `git diff $(git merge-base origin/main HEAD)`, plus
  untracked files from `git status --short`.
- **One task of a plan:** the base is the commit named in the brief's
  `Starts from:` line (`git log --grep -F "<title>" --format=%H -1`). Without
  one, review the whole branch and say so.

## 2. What was asked

- **Plan task:** the brief - Goal, Try it, Tests, Not in this task, and the
  decisions it lists.
- **Someone else's PR:** its description, plus what the user said it is for.
- **Neither:** write a short description of what was asked from the original
  request, not the code. **Have the user confirm it before reviewing.**

## 3. Context

- The repository's rules (`CLAUDE.md` and what it points to) for the areas
  touched, the module docs, and review notes
  (`~/.claude/plans/<project>/review-notes.md` or wherever the rules say).
  A broken rule is a finding, and the rule is the evidence. If there are no
  rules, say so; do not invent any.
- Whether CI is green, whether the branch is behind `main`
  (`git merge-base --is-ancestor origin/main <branch>`), and what earlier
  reviewers already said, so you do not repeat it.

## 4. Check

- **Against the request:** each part done, missing, or done differently from a
  decision; anything changed that was not asked for.
- **Defects:** wrong results for some input, a contract that differs from the
  rest of the codebase, migrations and data changes that cannot be rolled
  back, tests that would still pass if the behaviour broke, docs the change
  makes wrong.
- **Claims** in the description: verify them by running the code, fetching the
  spec or comparing data with a script.
- **Other work in progress:** name which branch has to change if it clashes.

**A finding needs a concrete input and the damage it causes.** If you cannot
show that, it goes under "Worth discussing".

## 5. Tests

Run them when the change touches logic and CI is red or missing, using the
project's test command. For a PR or pushed branch, run them in a worktree in
the scratchpad. For local changes, run them in the working copy. Never stash,
check out or reset anything, and never reset a database. Report what you could
not run.

## 6. Report

Most costly first. Say what breaks once; do not quote the code back.

```markdown
## Does it do what was asked
One line per part: done, missing or different; plus anything not asked for.

## Should change
**1. <The defect in one sentence>.** Where, what input, what happens. **Fix:** ...

## Worth discussing
Design questions and what you could not verify.

## Minor
One line each.

## Could not check
What was not run or verified, and why.
```

## Posting

Only when the user asks. Read `references/github.md` first, and leave the
review pending for the user to submit.
