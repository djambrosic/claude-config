---
name: align
description: Get on the same page before any work starts - ground yourself in the repository, then ask the user rounds of plain-language questions until nothing is unclear, restating the story after each round and writing every answer down as a decision. Use it whenever the user says "align", "grill me", "ask me questions", "let's figure this out", "how would we do X", or hands over a request that is vague, big or has several sensible readings. It stands alone for any request, and the plan skill starts with it.
---

# Align

The goal is that you and the user mean the same thing by every part of the
story - what it does, for whom, what it refuses, and how it is built - before
anything is built or planned. **Ask too many questions rather than too few.** A
question that turns out to be obvious costs a minute; a misunderstanding found
in the build costs a task.

**No code and no plan until the user says we are aligned.** Not a "start on the
easy part", not a "scaffold it meanwhile".

## Ground yourself first

So that the questions are informed, and none of them could have been answered
by reading:

- Read the repository's own rules - `CLAUDE.md` and whatever it points to.
  They are mostly a list of mistakes already made there.
- If it keeps module docs, read the doc for each module the story touches.
- Find the code that already does something similar and read it. New work that
  looks like the neighbouring work is worth more than new work that is cleverer.
  Note the file paths and the traps as you go.
- If there is a specification, find the actual paragraph and keep it - quoted
  in the PRD, never cited in the code.

### Let a cheaper model do the reading

Reading the repository is the biggest cost here and needs no deep judgment, so
hand it to one read-only Explore agent on a cheaper model (Haiku or Sonnet).
You keep the questions and the conclusions.

- **One agent per research task**, never several re-reading the same files.
- **Tell it what to find**, not "explore the code": which rules apply, which
  existing code does something similar (paths), the traps, whether the project
  has tests.
- **Tell it what to leave out.** Give it the paths of what is already written
  down - the plan folder, `prd.md`, `decisions.md`, the repository's rules and
  docs - and have it report only what is not in them. Where something exists
  already, it names the file instead of copying the content.
- **Short summary back**, about 30 lines: findings with file paths, then what
  it could not find. No file dumps.
- The agent only reads. Questions, decisions and conclusions stay with you.

If the area is small and you already know the files, read them yourself.

Ask in rounds of up to about ten numbered questions. Use the question tool
when a question has two to four clear options, and plain numbered text when it
is open. After each round:

1. Write the answers into `decisions.md` straight away (see below).
2. Restate the story as you now understand it, in a short paragraph or a few
   bullets, so the user can catch a misunderstanding.
3. Ask the next round - the follow-ups the answers raised, and the areas not
   yet covered.

Keep going until a round turns up nothing new and the user agrees with your
restatement. Do not stop because it feels like a lot of questions; that is the
point.

Cover at least these, in whatever order the story suggests:

- **Who and why** - who uses this, what problem it solves for them, what they
  do today instead.
- **What they can do** - each action, one by one. For each: what goes in, what
  comes out, what is stored.
- **What is refused** - every rule that says no, and what the person sees then.
- **Edge cases** - empty, duplicate, too big, at the same time, after a
  change, after a delete.
- **Who may do what** - permissions, and who sees which data.
- **Data** - what is kept, where it comes from, how long it lives, what
  changes it.
- **What exists** - what is reused, what is changed, what is replaced.
- **How it is built** - the approach. When there is more than one sensible
  way, lay them out with what each costs and say which you recommend and why.
  If you think the request itself is the wrong approach, say so and propose
  a better one. Small technical details - a name, an error code, a rounding
  step - are yours to decide: write them into `decisions.md` and list them in
  the round's restatement, so the user can overturn them.
- **How we know it works** - what the user would try to be convinced.
- **Scope** - what is deliberately not part of this story, and what comes
  later.

## Write every question in plain language

**Write every question so a junior in that field would understand it.** If the
work is BI, picture a junior BI analyst; if it is finance, a junior accountant;
if it is code, a junior developer. That means:

- Ordinary words. If a technical term is unavoidable, explain it in half a
  sentence the first time.
- Say what the choice actually changes for the person or the business, not
  only how it is built.
- Give concrete options to pick from, each with what it means in practice.
  "Show the total with or without VAT?" beats "What is the tax treatment of the
  aggregate?".
- One question asks one thing.

Bad: *"Should the recalculation be idempotent with respect to the factor
direction?"*
Good: *"When a price is recalculated, should running it twice give the same
result as running it once? Yes is safer. No is only needed if each run is meant
to add on top of the last."*

The same rule applies to every decision put to the user later, and to the
questions document.

## Decisions, as they are made

`decisions.md`, from `assets/decisions-template.md`, is a numbered list of
everything settled, each one short enough to read at a glance:

```markdown
### 4. A reservation expires after three days - decided

Members kept books reserved for weeks. Three days matches how long the desk
holds a book that came back.
```

The title is the decision itself, not the topic ("A reservation expires after
three days", not "Reservation expiry"). Underneath, one to three sentences on
why. If something was rejected and someone will ask about it, one more line:
`Not chosen: ...`. Nothing longer - a decision that needs a page is really
several decisions, or belongs in the PRD.

Mark one **decided for now** when it is settled enough to build on but
expected to come back. Write decisions while the reasoning is fresh; a
decision reconstructed a week later is a guess.

**Where it goes.** If the work has a plan folder
(`~/.claude/plans/<project>/<topic>/`), write `decisions.md` there. If not,
and the work is small, keep the decisions in the conversation and list them in
your restatement. Do not create a plan folder for a one-sitting job.

## What is still open

An answer that is not available yet goes into the Open questions table at the
bottom of `decisions.md`, labelled:

- **Blocking** - the answer changes the design or the first tasks. While any
  blocking question is open, the work does not move on.
- **Parked** - the answer affects only one part. The tasks that depend on it
  are marked `[!]` with the question number and wait; the rest can go ahead.

If you are unsure which it is, treat it as blocking and say why.

**Never write down an assumption and build on it.** "We'll assume forever
until finance answers" is exactly the guess this rule exists to stop.

## The questions document

When an answer has to come from someone outside the session - a colleague, the
client, finance - write `questions-for-<who>.md` from
`assets/questions-template.md`. The user forwards it, so it has to make sense
to someone who has never seen the plan:

- English, and the same plain-language rule as above.
- A short opening: what is being built, and why their answer is needed.
- Per question: the background in two or three sentences, the options with
  what each one means for them, what happens if they do not answer (which part
  waits), and whether it is blocking.
- Blocking questions first.
- No file paths, class names or plan jargon.

Tell the user the file is ready and who it is for. When answers come back, add
them as decisions, remove the row from Open questions, and unblock what waited.

## Done

When a round turns up nothing new and the user says we are aligned, stop and
say what is settled and what is still open. Moving on - to a PRD, a plan, or
building - starts only when the user asks.
