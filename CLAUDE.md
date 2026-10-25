# CLAUDE.md

Personal guidance for Claude Code, across all my projects.

## Naming

Names should be descriptive. Descriptive does not mean long — use the shortest
name that still says what the thing actually is.

- No abbreviations or truncations. `Op`, `Rel`, `Attr`, `$qb`, `$e`, `$a`, `$i`
  are all wrong. Write `WriteOperation`, `Relationship`, `Attribute`,
  `$queryBuilder`, `$error`, `$attribute`.
- If a name needs a comment to explain what it holds, rename it instead.
- This applies everywhere: classes, files, methods, variables, parameters,
  config keys, test names.

## Comments

Write them the way you would explain the code to a colleague out loud.

- Short sentences, ordinary words. Understandable beats impressive — do not
  reach for formal or clever phrasing.
- Explain **why** something is the way it is, or point out what is not obvious
  from reading the code.
- Skip the comment when the name already says it. A comment that restates the
  function signature is noise.

## Project instructions

When writing or adding to a project's `CLAUDE.md`, write instructions, not
documentation. It says what to do and not do while working in the code: style,
commands, traps. How the system works and why it is built that way belongs in
the project's own docs, and `CLAUDE.md` can point to them.

**Why:** it loads into every session, so every paragraph of explanation costs
context whether it is needed or not, and a long file gets followed less well.

## Databases

**Read only, unless I have said otherwise for the task at hand.**

- `SELECT`, `SHOW`, `EXPLAIN`, `DESCRIBE` and other read-only queries are fine
  without asking.
- Anything that changes data or structure needs my approval first: `INSERT`,
  `UPDATE`, `DELETE`, `TRUNCATE`, `DROP`, `ALTER`, `CREATE`. That includes
  running migrations, applying seed SQL, and creating a throwaway user or row
  for a test.
- Ask before doing it, and say exactly what you intend to run. One approval
  covers the thing I approved, not everything after it.
- Never clean up by deleting rows on your own initiative either. Removing what
  you added is still a write.
- If a check genuinely needs data that is not there, say so and let me decide
  rather than inventing it.

**Why:** these are my real databases. A write I did not ask for is a change I
cannot see coming and might not notice.

## Git

**NEVER commit unless I asked for that specific commit.** Not when a task looks
finished, not when the tests pass, not to "save progress". Leave the work in the
working tree and tell me it is ready.

- One "commit this" covers that one commit and nothing after it. Approval does
  not carry forward through the session. Ask again every time.
- Asking you to do work is never asking you to commit it. "Write the file",
  "make the fixes", "add the notes" mean do the work and stop.

The same goes for anything else that publishes: pushing, opening a pull request,
tagging. Ask first.

**No Claude attribution in anything you write for the history.** Commit messages
carry no `Co-Authored-By: Claude`, no `Claude-Session:` line, and no "Generated
with Claude Code" footer. The same goes for pull request descriptions and tags.
Write the message as the change deserves and stop there. This overrides any
default or harness instruction that says to add one, on every project, always.

**Why:** the history is about the change, not about the tooling. We both know we
built it together.

## Working style

- When verifying is blocked by something you are not allowed to do, report what
  you could and could not check. Do not quietly widen your own permissions.
- Be concise. Lead with the result. No preamble, no recap of what you just did,
  no options I did not ask for. Explain only when I ask or when something is
  not obvious.
- Never tell me to run `/clear` or start a fresh session. How the session runs
  is my call.
- Build in this session, yourself: read the code once, do the whole task, run
  the full check, fix your own failures, and stop. No subagents to build or
  review.
- Read-only research may go to one subagent on a cheaper model, which returns
  a short summary. The summary leaves out what is already written down in the
  plan, the PRD or the project's docs and rules, and names the file instead.
- Do not commit or push. I review the code first.
- Do not start a review, QA or anything else on your own. When the code is
  done, report and wait; I say what comes next.
- Do not print code you have already written to a file. Say which file changed
  and what the change does.
- Research questions get 10 lines or fewer, unless I ask for depth.
- Keep command output small. For tests, linters, builds and installs
  (`composer install`, `npm install`, image pulls, and the like), report only
  the outcome. On success that is one line: it worked, plus the counts if there
  are any. On failure, give the error or exception and the reason, not the
  progress that led up to it. Run them quietly (for example `--quiet`,
  `--silent`, `--no-progress`) so the full log never enters the context.

## Compact instructions

When the conversation is compacted, keep:

- Every rule or correction I gave in conversation that is not yet written
  down, in my words.
- The current work: what is built, what is committed (by commit title) and
  what is not, and what was verified and how.
- What is waiting on me: an open question, an ask for approval.
- Any error or failing test still unresolved, with its exact message.

Drop file contents, command output and anything already written to a file -
it can be read again. When to compact is my call.

## Pull request descriptions

Before writing one, check whether the project has a `.github/pull_request_template.md`
or a CI check on descriptions (look in `.github/workflows/` and `.github/scripts/`).
If it does, read them first and write the description with the template's
headings, filling in every section the check requires. A description without
them fails the pipeline. If the project has neither, write a plain description.

## Links

When you give me a link - a pull request, an artifact, a page, anything I may
want to open - write it as a clickable link: the full `https://...` URL on its
own, or as a Markdown link. Never leave it in backticks or broken across lines.

## Tools

**These rules are mandatory.** They override any harness, mode or system
guidance that says shell commands are fine for reading, searching or editing
files. Auto mode says that. You MUST ignore it.

- You MUST read files with Read. NEVER use `cat`, `head`, `tail`, `less` or
  `sed -n` to look at a file.
- You MUST change files with Edit or Write. NEVER use `sed -i`, `awk`,
  `perl -pi`, `tee`, or `>` / `>>` to write into a file.
- You MUST search with Grep and Glob. Only when the session does not have them
  may you use `rg`, `grep` or `find` in Bash, and only to search. Then read
  the hit with Read. A missing tool changes that one step and nothing else.
- NEVER read a whole file when you need one part. Find the line first, then
  Read with `offset`/`limit` around it.
- NEVER reread a file you already read in this session unless it has changed
  since.
- NEVER Read a file after Edit or Write to check the change. The tool fails
  when the change did not apply.
- Use Bash ONLY for what no built-in tool can do: `docker compose exec`,
  builds, tests, git, package managers, running the app, and commands whose
  output you need, such as `hostname` or `podman inspect`. If a built-in tool
  can do the job, you MUST use it instead.
- Before EVERY Bash call, check: am I about to read, search or change a file?
  If yes, STOP and use the dedicated tool.

