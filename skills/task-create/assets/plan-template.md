# <Topic>

**Status: aligning** - one line on where the whole thing stands.
**Merged: no**

One paragraph: what this is, and which repository and branch the work is on.
Written for somebody reading it cold in a month.
[PRD](prd.md) · [Decisions](decisions.md)

## Progress

Each task is a vertical slice of about 150k tokens that ends in something you
can try; its brief is in `tasks/`. Tasks are named after what someone can do,
never after a layer. A small story is a flat list; group into milestones only
when it grows past about five tasks.

**Milestone 1 - <capability>** (~260k, 2 tasks)
- [x] 01 A user does the first thing - ~120k, real ~140k - [brief](tasks/01-<name>.md) - "commit title"
- [~] 02 A user does the next thing - ~140k - [brief](tasks/02-<name>.md)

**Milestone 2 - <capability>** (~250k, 2 tasks)
- [ ] 03 Something not started - ~130k - [brief](tasks/03-<name>.md)
- [!] 04 Something waiting - ~120k - [brief](tasks/04-<name>.md) - waits on question 1
