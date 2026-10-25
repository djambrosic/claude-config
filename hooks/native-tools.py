#!/usr/bin/env python3
"""Stop Claude from reading, searching or editing files through Bash.

PreToolUse hook on Bash. It looks at the start of each command in the line
(split on &&, ||, ; and newlines, but not on pipes), so `git log | grep x`
still works: filtering a command's output is fine, reading a file is not.

Searching (grep, rg, find) is only blocked when CLAUDE_NATIVE_SEARCH=1. The
`claude` shell function sets it together with --allowedTools Grep,Glob, and
without that flag this native build has no Grep or Glob tool, so blocking
the shell would leave no way to search at all.
"""

import json
import os
import re
import shlex
import sys

READ_TOOL = "Use the Read tool (with offset/limit for one part of a file)."
EDIT_TOOL = "Use the Edit or Write tool."
GREP_TOOL = "Use the Grep tool."
GLOB_TOOL = "Use the Glob tool."

# The command word, then what to say about it.
ALWAYS_BLOCKED = {
    "cat": READ_TOOL,
    "head": READ_TOOL,
    "tail": READ_TOOL,
    "less": READ_TOOL,
    "more": READ_TOOL,
    "tee": EDIT_TOOL,
}

SEARCH_BLOCKED = {
    "grep": GREP_TOOL,
    "egrep": GREP_TOOL,
    "fgrep": GREP_TOOL,
    "rg": GREP_TOOL,
    "ugrep": GREP_TOOL,
    "ag": GREP_TOOL,
    "find": GLOB_TOOL + " To search contents, use the Grep tool.",
    "fd": GLOB_TOOL,
    "bfs": GLOB_TOOL,
}

SEGMENT_SEPARATOR = re.compile(r"&&|\|\||;|\n")
ENVIRONMENT_ASSIGNMENT = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*=")


def command_words(segment):
    try:
        words = shlex.split(segment, posix=True)
    except ValueError:
        words = segment.split()
    # Skip `FOO=bar cmd`, `command cmd`, `sudo cmd` and the like, so the
    # real command is what gets checked.
    while words and (ENVIRONMENT_ASSIGNMENT.match(words[0]) or words[0] in ("command", "builtin", "sudo", "nice", "time", "do", "then", "else", "{", "(")):
        words = words[1:]
    return words


def reason_for(words, search_blocked):
    if not words:
        return None
    program = os.path.basename(words[0])
    arguments = words[1:]

    if program in ALWAYS_BLOCKED:
        return ALWAYS_BLOCKED[program]
    if program == "sed" and any(argument == "-n" or argument.startswith("-i") for argument in arguments):
        return READ_TOOL if "-n" in arguments else EDIT_TOOL
    if program == "awk" and arguments:
        return READ_TOOL + " To change a file, use the Edit tool."
    if program == "perl" and any(re.match(r"^-\w*i", argument) for argument in arguments):
        return EDIT_TOOL
    if search_blocked and program in SEARCH_BLOCKED:
        return SEARCH_BLOCKED[program]
    return None


def main():
    payload = json.load(sys.stdin)
    if payload.get("tool_name") != "Bash":
        return
    command = payload.get("tool_input", {}).get("command", "")
    search_blocked = os.environ.get("CLAUDE_NATIVE_SEARCH") == "1"

    segments = SEGMENT_SEPARATOR.split(command)
    # tee writes a file wherever it sits, so it is checked after pipes too.
    segments += [part for segment in segments for part in segment.split("|")[1:] if command_words(part.strip())[:1] == ["tee"]]

    for segment in segments:
        reason = reason_for(command_words(segment.strip()), search_blocked)
        if reason:
            program = command_words(segment.strip())[0]
            print(json.dumps({
                "hookSpecificOutput": {
                    "hookEventName": "PreToolUse",
                    "permissionDecision": "deny",
                    "permissionDecisionReason": f"Do not use `{program}` on files in Bash. {reason} "
                    "Pipes that filter another command's output (`git log | grep x`) are still fine.",
                }
            }))
            return


if __name__ == "__main__":
    main()
