#!/usr/bin/env bash
#
# Links this repository's Claude Code setup into ~/.claude.
#
#   ./install.sh             install, asking before touching anything that exists
#   ./install.sh --dry-run   show what would happen, change nothing
#
# Safe to run again: anything already linked here is left alone.
# Set CLAUDE_HOME to install somewhere other than ~/.claude.

set -euo pipefail

repo_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
claude_directory="${CLAUDE_HOME:-$HOME/.claude}"
# Backups go in a hidden folder of their own. Beside the original they would be
# found as extra skills, because Claude Code loads every folder under skills/.
backup_directory="$claude_directory/.config-backups/$(date +%Y%m%d-%H%M%S)"
dry_run=false

if [ "${1:-}" = "--dry-run" ]; then
  dry_run=true
elif [ -n "${1:-}" ]; then
  echo "Unknown option: $1" >&2
  exit 1
fi

# Without a terminal we cannot ask, so anything that needs a decision is skipped.
if [ -t 0 ]; then
  interactive=true
else
  interactive=false
fi

# Asks a question and prints the answer. $1 is the question, $2 the choices
# written the way the user sees them, such as "y/n". One letter is enough.
ask() {
  local question="$1" choices="$2" answer
  local allowed_keys="${choices//\//}"
  while true; do
    read -r -p "$question [$choices] " answer
    answer="$(printf '%s' "${answer:0:1}" | tr '[:upper:]' '[:lower:]')"
    if [[ "$answer" =~ ^[$allowed_keys]$ ]]; then
      echo "$answer"
      return
    fi
    echo "  Please type one of: $choices" >&2
  done
}

make_link() {
  local source_path="$1" target_path="$2"
  if $dry_run; then
    echo "  would link $target_path"
    return
  fi
  mkdir -p "$(dirname "$target_path")"
  ln -s "$source_path" "$target_path"
  echo "  linked $target_path"
}

# Links one file or folder, and asks what to do when something is in the way.
install_item() {
  local source_path="$1" target_path="$2" choice

  if [ -L "$target_path" ] && [ "$(readlink "$target_path")" = "$source_path" ]; then
    echo "  already linked $target_path"
    return
  fi

  if [ ! -e "$target_path" ] && [ ! -L "$target_path" ]; then
    make_link "$source_path" "$target_path"
    return
  fi

  echo "  exists: $target_path"
  local same_content=false
  if diff -rq "$target_path" "$source_path" > /dev/null 2>&1; then
    same_content=true
    echo "  same content as this repository's copy"
  fi
  if ! $interactive; then
    echo "  skipped (no terminal to ask on)"
    return
  fi

  while true; do
    choice="$(ask "  Skip, replace (keeps a backup) or show the diff?" "s/r/d")"
    case "$choice" in
      s)
        echo "  skipped"
        return
        ;;
      r)
        local backup_path="$backup_directory/${target_path#"$claude_directory"/}"
        if $dry_run; then
          echo "  would back up to $backup_path and link"
        else
          mkdir -p "$(dirname "$backup_path")"
          mv "$target_path" "$backup_path"
          echo "  backed up to $backup_path"
        fi
        make_link "$source_path" "$target_path"
        return
        ;;
      d)
        if $same_content; then
          echo "  no differences, skipped"
          return
        else
          diff -ru "$target_path" "$source_path" || true
        fi
        ;;
    esac
  done
}

# CLAUDE.md is the file people most often already have, so ours goes in beside
# it under another name, and one import line in theirs pulls it in.
install_instructions() {
  local import_line="@claude-config.md"
  local user_file="$claude_directory/CLAUDE.md"

  install_item "$repo_directory/CLAUDE.md" "$claude_directory/claude-config.md"

  if [ -f "$user_file" ] && grep -qxF "$import_line" "$user_file"; then
    echo "  $user_file already imports claude-config.md"
    return
  fi

  if ! $interactive; then
    echo "  add the line '$import_line' to $user_file to use these rules"
    return
  fi

  if [ "$(ask "  Add '$import_line' to $user_file?" "y/n")" != "y" ]; then
    echo "  not added; add '$import_line' to $user_file yourself to use these rules"
    return
  fi

  if $dry_run; then
    echo "  would add '$import_line' to $user_file"
    return
  fi
  printf '\n%s\n' "$import_line" >> "$user_file"
  echo "  added '$import_line' to $user_file"
}

echo "Installing into $claude_directory"
$dry_run && echo "(dry run, nothing is changed)"

echo "Instructions"
install_instructions

echo "Status line"
install_item "$repo_directory/statusline-command.sh" "$claude_directory/statusline-command.sh"

echo "Hooks"
for hook_path in "$repo_directory"/hooks/*; do
  install_item "$hook_path" "$claude_directory/hooks/$(basename "$hook_path")"
done

echo "Agents"
for agent_path in "$repo_directory"/agents/*; do
  install_item "$agent_path" "$claude_directory/agents/$(basename "$agent_path")"
done

echo "Skills"
for skill_path in "$repo_directory"/skills/*/; do
  skill_path="${skill_path%/}"
  install_item "$skill_path" "$claude_directory/skills/$(basename "$skill_path")"
done

cat <<MESSAGE

Done. Two things this script does not touch, because they live in
settings.json and merging JSON by hand-rolled script is how files get broken:

  - the status line:  "statusLine": {"type": "command", "command": "bash ~/.claude/statusline-command.sh"}
  - the Bash hook:    a PreToolUse hook on "Bash" running python3 ~/.claude/hooks/native-tools.py

See settings.example.json for both, and add them to ~/.claude/settings.json.
MESSAGE
