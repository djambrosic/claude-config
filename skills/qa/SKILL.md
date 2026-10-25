---
name: qa
description: Test a finished story or task from the outside - write scenarios in user terms from the PRD and task briefs, matched to what changed (API only, or screens and API together), then have the qa agent walk them on the running app without reading the code, and bring back a report. Use it when the user says "qa this", "test the flow", "walk it through", "write scenarios", or asks whether a story really works for the people who will use it. Runs only when asked.
---

# QA from the outside

Two steps: you write the scenarios, then the `qa` agent runs them. The agent
never sees the code, so it finds what a real user or a frontend developer would
find: the docs that guess, the screen that confuses, the answer that does not
say what to do.

Do not start this on your own. The user asks for it.

## 1. Write the scenarios

Work from the story, not the code: the PRD's behaviours, `decisions.md`, and the
"Try it" part of each task brief, in `~/.claude/plans/<project>/<topic>/`. If
there is no plan folder, work from what the user tells you.

Match the scenarios to what changed:

- **Only the API changed** - scenarios are requests and the answers people
  rely on: what is sent, what comes back, what is refused and with which
  message.
- **Screens and API changed** - scenarios are journeys a person takes through
  the screens. The API checks sit under them, for what a screen shows and
  cannot get wrong.
- **Something else** (a command, a mail, a scheduled job) - the scenario says
  what the person runs or receives.

Cover for each behaviour: the happy path, every refusal in the PRD, and the
edges (empty, duplicate, too big, wrong person, already done). A scenario is
one flow with a clear start; do not cram unrelated behaviours into one.

Save each in `~/.claude/plans/<project>/<topic>/qa/NN-<name>.md`:

```markdown
# <What the person does>

**Who:** the people in the scenario and how they sign in (names and roles; the
password goes to the agent in the prompt, never in the file).
**Goal:** what they are trying to do, in their words.

## Environment
Where the app runs, how to sign in, what must be running first (workers, mail
catcher, seed data). Copy it from the project's environment notes (below),
never from the code.

## What to read
The documentation the agent may use: paths or URLs of the API docs, user
guide, screens. Nothing else.

## Steps
1. What the person does, then what they expect to see or get back.
2. ...

## Refusals and edges
- What should be refused, and what the person should be told.
```

**Environment notes.** The agent cannot read code, so the facts about running
the app come from you. Keep them per project in
`~/.claude/plans/<project>/qa-environment.md`: base URL, how to sign in,
required services, where mail lands, how to start things. If the file is
missing, ask the user for the facts and write it. Never invent them.

**Never hand the agent exact requests or clicks** beyond what a user of the
docs would know. The point is to find where someone would get stuck.

## 2. Run them

Start the `qa` agent with one scenario at a time. In the prompt give it the
scenario file's path and, if it signs in, the password. Do not give it the code,
the tests, or your reasoning about the answer.

For screens, the agent drives the browser; for an API, it uses a script. Both
are in its own instructions.

## 3. Bring the report back

The agent's final reply is the report. Save it as `report.md` beside the
scenario, then tell the user, briefly:

- which steps passed and which did not;
- where the docs or screens let the agent down;
- what you think is a real bug and what is a docs gap.

Do not fix anything as part of the QA run. The user decides what comes next.
