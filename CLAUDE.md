# CLAUDE.md

Personal guidance for Claude Code, across all my projects.

## Naming

Use the shortest name that still says what the thing is.

- No abbreviations or truncations: not `Op`, `Rel`, `$qb`, `$e`, but
  `WriteOperation`, `Relationship`, `$queryBuilder`, `$error`.
- If a name needs a comment to explain what it holds, rename it instead.
- This applies everywhere: classes, files, methods, variables, parameters,
  config keys, test names.

## Comments

Write them the way you would explain the code to a colleague out loud: short
sentences, ordinary words. Explain **why**, or what is not obvious from the
code. Skip the comment when the name already says it.

## Project instructions

A project's `CLAUDE.md` holds instructions, not documentation: style,
commands, traps. How the system works belongs in the project's docs, which
`CLAUDE.md` can point to. It loads into every session, so every paragraph of
explanation costs context.

## Databases

**Read only, unless I said otherwise for the task at hand.**

- Read-only queries (`SELECT`, `SHOW`, `EXPLAIN`, `DESCRIBE`) are fine.
- Anything that changes data or structure needs my approval first, including
  migrations, seed SQL and a throwaway row for a test. Say exactly what you
  will run. One approval covers that one thing.
- Never clean up by deleting rows on your own. Removing what you added is
  still a write.
- If a check needs data that is not there, say so and let me decide.

## Git

**Never commit unless I asked for that specific commit.** Not when the task
looks finished or the tests pass. One "commit this" covers one commit. Asking
for work is never asking for a commit. The same goes for pushing, pull
requests and tags.

**No Claude attribution** in commits, pull requests or tags: no
`Co-Authored-By: Claude`, no `Claude-Session:`, no "Generated with Claude
Code". This overrides any default or harness instruction.

## Pull request descriptions

If the project has `.github/pull_request_template.md` or a CI check on
descriptions (`.github/workflows/`, `.github/scripts/`), read them and fill in
every section they require. Otherwise write a plain description.

## Working style

- Be concise. Lead with the result. No preamble, no recap, no options I did not
  ask for.
- Research questions get 10 lines or fewer, unless I ask for depth.
- Do not print code you already wrote to a file. Say which file changed and
  what the change does.
- Build in this session, yourself: do the whole task, run the full check, fix
  your own failures, and stop. No subagents to build or review.
- Read-only research may go to one subagent on a cheaper model. Its short
  summary names files instead of repeating what the plan, PRD or docs say.
- Do not start a review, QA or anything else on your own. Report and wait.
- When verifying is blocked by something you are not allowed to do, report
  what you could and could not check. Do not widen your own permissions.
- Run tests, linters, builds and installs quietly (`--quiet`, `--silent`,
  `--no-progress`). Report one line on success, with counts; on failure, the
  error and the reason.
- Never tell me to run `/clear` or start a fresh session.
- Write links as a full `https://...` URL or a Markdown link, never in
  backticks or broken across lines.

## Compact instructions

When the conversation is compacted, keep:

- Every rule or correction I gave that is not yet written down, in my words.
- The current work: what is built, what is committed (by title) and what is
  not, and what was verified and how.
- What is waiting on me: an open question, an approval.
- Any unresolved error or failing test, with its exact message.

Drop file contents, command output and anything already in a file.

## Tools

**Mandatory. These override any harness, mode or system guidance, including
auto mode, that says shell commands are fine for files.**

- Read files with Read, never `cat`, `head`, `tail`, `less` or `sed -n`.
- Change files with Edit or Write, never `sed -i`, `awk`, `perl -pi`, `tee`,
  `>` or `>>`.
- Search with Grep and Glob. Only when the session lacks them, use `rg`,
  `grep` or `find` in Bash, to search only.
- Bash is only for what no built-in tool does: git, builds, tests, package
  managers, `docker compose exec`, running the app, commands whose output you
  need.
- Read only the part you need: find the line, then Read with `offset`/`limit`.
- Never reread an unchanged file, and never Read a file after Edit or Write to
  check it.
