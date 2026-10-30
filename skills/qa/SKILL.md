---
name: qa
description: Test a finished story or task from the outside - write scenarios in user terms from the PRD and briefs, have the qa agent walk them on the running app without reading code, and report back. Use when the user says "qa this", "test the flow", "walk it through" or "write scenarios". Runs only when asked.
---

# QA from the outside

You write the scenarios; the `qa` agent runs them without seeing the code, so
it gets stuck where a real user or frontend developer would. Run only when the
user asks.

## 1. Write the scenarios

Work from the story, not the code: the PRD's behaviours, `decisions.md` and each
brief's "Try it", in `~/.claude/plans/<project>/<topic>/`. With no plan folder,
work from what the user tells you.

Match them to what changed:

- **API only** - requests and answers: what is sent, what comes back, what is
  refused and with which message.
- **Screens and API** - journeys through the screens, with API checks under
  them for what a screen shows.
- **Something else** (command, mail, scheduled job) - what the person runs or
  receives.

Per behaviour, cover the happy path, every refusal in the PRD, and the edges:
empty, duplicate, too big, wrong person, already done. One flow per scenario.

Save each as `qa/NN-<name>.md` in the plan folder, from
`assets/scenario-template.md`. Never give exact requests or clicks beyond what a
reader of the docs would know.

**Environment** comes from `~/.claude/plans/<project>/qa-environment.md`: base
URL, sign-in, required services, where mail lands, how to start things. If it
is missing, ask the user and write it. Never invent it, and never take it from
the code.

## 2. Run them

Start the `qa` agent with one scenario at a time: the scenario's path and, if
it signs in, the password. Not the code, the tests or your expectations.

## 3. Report

Save the agent's reply as `qa/NN-<name>-report.md`, beside its scenario. Tell the user which
steps passed and which failed, where the docs or screens let the agent down,
and which failures look like real bugs and which like docs gaps. Fix nothing.
