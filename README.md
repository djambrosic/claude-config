# claude-config

My Claude Code setup, for any project and any stack: global rules, a few
skills that take a piece of work from a vague idea to reviewed code, a status
line, and one hook. Take what you like.

## Install

```bash
git clone <this repository> ~/claude-config
cd ~/claude-config
./install.sh --dry-run   # see what it would do
./install.sh
```

The script symlinks everything into `~/.claude`, so a `git pull` updates it.
If something is already there it asks: skip, replace (the old one is moved to
`~/.claude/.config-backups/<time>/`), or show a diff. Your own `CLAUDE.md` is never
replaced: the rules go in as `claude-config.md`, and the script offers to add
one `@claude-config.md` line to your `CLAUDE.md`.

It does not edit `settings.json`. Add the status line and the hook from
`settings.example.json` yourself.

Needs `bash`, `python3` and, for the status line, `jq`. Linux and macOS.

## Use as a plugin

The repository is also a plugin named `workflow`. It carries the skills (as
`/workflow:<skill>`), the `qa` agent and the Bash hook.

```bash
/plugin marketplace add Cindervane/cindervane-plugins
/plugin install workflow@cindervane-plugins
./install.sh --rules-only   # rules and status line, which plugins cannot carry
```

- Never combine the plugin with a full `./install.sh` on one machine: the
  skills would load twice and the hook would run twice.
- To publish a change, bump `version` in `.claude-plugin/plugin.json` and push.
  Without a new version, installed copies do not update.

## What is in it

| Path | What it is |
|---|---|
| `CLAUDE.md` | Global rules: naming, comments, databases read-only, git (no commit without asking, no attribution), tools, concise output |
| `statusline-command.sh` | Model, folder, context bar with absolute tokens (warning colour from 200k), 5-hour limit, and session cost against a budget when `CLAUDE_STATUSLINE_BUDGET_USD` is set |
| `hooks/native-tools.py` | Stops `cat`, `find`, `sed` and friends in Bash and points to Read, Grep, Glob and Edit |
| `agents/qa.md` | A tester that never sees the code: it walks a scenario through the running app and reports where the docs or screens let it down |
| `skills/` | The workflow below, plus `review` |

## The workflow

Each skill works alone. Together they go from a request to reviewed code, and
each step ends only when you say so.

1. **`align`** - rounds of plain-language questions, until nothing is unclear.
   Every answer is written down as a decision.
2. **`plan`** - the agreed story as a short PRD.
3. **`task-create`** - the PRD cut into vertical slices: one behaviour through
   every layer, each ending in something you can try. Writes `plan.md` as a
   checklist and one standalone brief per task.
4. **`execute-tasks`** or **`execute-tasks-tdd`** - build one task. The second
   is test-first (red, green, refactor) and is for projects that have tests.
5. **`qa`** (when asked) - writes scenarios from the story, matched to what
   changed (API, screens, or both), and has the `qa` agent walk them.
6. **`review`** (when asked) - reviews a pull request, branch or working tree
   against the request and the repository's own rules. Posts nothing without
   your say-so.

Plans live outside the repository, in
`~/.claude/plans/<project>/<topic>/`: `prd.md`, `decisions.md`, `plan.md`,
`tasks/`, `handoff.md` from the last build session, `qa/`, and anything else
for the topic.

## Make it yours

`CLAUDE.md` holds my preferences. Change them, or keep your own `CLAUDE.md`
and import this one. Project-specific notes belong in the project's own rules,
or, for reviews, in `~/.claude/plans/<project>/review-notes.md`.

## License

[MIT](LICENSE)
