---
name: align
description: Get on the same page before work starts - read the repository, then ask rounds of plain-language questions and record the answers as decisions. Use when the user says "align", "grill me", "ask me questions" or "let's figure this out", or gives a vague, big or ambiguous request. The plan skill starts with it.
---

# Align

The goal is that you and the user mean the same thing by every part of the
story - what it does, for whom, what it refuses, and how it is built - before
anything is built or planned. Ask enough to remove every real doubt, and no
more. Match the depth to the request: a small change may need one round, a new
feature several.

**No code and no plan until the user says we are aligned.** Not a "start on the
easy part", not a "scaffold it meanwhile".

## Ground yourself first

No question should be one that reading could have answered.

- Read the repository's rules - `CLAUDE.md` and whatever it points to - and the
  module docs for what the story touches.
- Find the code that already does something similar and read it. New work that
  looks like the neighbouring work beats new work that is cleverer. Note the
  paths and the traps.
- Read the files yourself. Only when the area is wide or unfamiliar, hand the
  reading to one read-only subagent on a cheaper model. Tell it what to find,
  give it the paths of what is already written down so it skips them, and ask
  for about 30 lines back with file paths. Questions and conclusions stay with
  you.

## Ask in rounds

Up to about ten numbered questions per round. Use the question tool when a
question has two to four clear options, plain numbered text when it is open.

Ask only about what is not already clear from the request or the code. Check
these areas, and skip the ones that do not apply or have an obvious answer:

- **Who and why** - who uses it, what problem it solves, what they do today.
- **What they can do** - each action: what goes in, what comes out, what is
  stored.
- **What is refused** - every rule that says no, and what the person sees then.
- **Edge cases** - empty, duplicate, too big, at the same time, after a change
  or delete.
- **Who may do what** - permissions, who sees which data.
- **Data** - what is kept, where it comes from, how long it lives.
- **What exists** - what is reused, changed or replaced.
- **How it is built** - when there is more than one sensible way, give each
  with its cost and recommend one. If the request itself is the wrong approach,
  say so.
- **How we know it works** - what the user would try to be convinced.
- **Scope** - what is deliberately left out, and what comes later.

Small technical details - a name, an error code, a rounding step - are yours to
decide. Do not ask about them; record them as decisions so the user can
overturn them.

After each round:

1. Add the new decisions to `decisions.md`.
2. Show only what changed: the new decisions, including the ones you made
   yourself, and anything that moved your understanding. Do not retell the
   whole story.
3. Ask the follow-ups and the areas still uncovered.

Stop when a round turns up nothing new.

## Plain language

Write every question so a junior in that field would understand it - a junior
BI analyst for BI work, a junior accountant for finance, a junior developer for
code. Ordinary words; explain an unavoidable term in half a sentence. Say what
the choice changes for the person or the business, and give concrete options.
One question asks one thing.

Bad: *"Should the recalculation be idempotent with respect to the factor
direction?"*
Good: *"When a price is recalculated, should running it twice give the same
result as running it once? Yes is safer. No is only needed if each run is meant
to add on top of the last."*

## Decisions

Use the format in `assets/decisions-template.md`: the title is the decision
itself, then one to three sentences on why.

If the work has a plan folder (`~/.claude/plans/<project>/<topic>/`), write
`decisions.md` there. If not and the work is small, keep the decisions in the
conversation. Do not create a plan folder for a one-sitting job.

An answer not available yet goes in the template's Open questions table,
marked blocking or parked. If unsure, it is blocking. **Never write down an
assumption and build on it.**

When the answer has to come from someone outside the session, write
`questions-for-<who>.md` from `assets/questions-template.md` and tell the user
it is ready and who it is for. When answers come back, add them as decisions
and remove the open question.

## Done

When a round turns up nothing new, give the full story once in a short
paragraph or a few bullets, with what is still open. Once the user says we are
aligned, stop. Moving on - to a PRD, a plan, or building - starts only when the
user asks.
