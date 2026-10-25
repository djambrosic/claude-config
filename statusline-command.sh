#!/usr/bin/env bash
# Claude Code statusLine, Tokyo Night themed.
#
# Renders:  Opus 5 folder [████░░░░░░] 100k/1000k | 5h limit: 12% (4h:22m)
#
# Every value comes from the JSON piped in on stdin (one jq call) plus bash
# builtins -- no git, hostname, or network subprocesses per render.
#
# Field paths verified against the Claude Code binary's statusline payload
# builder:
#   model.display_name                  active model, e.g. "Opus 5"
#   context_window.total_input_tokens   input + cache_creation + cache_read
#   context_window.total_output_tokens
#   context_window.context_window_size  max tokens for the active model
#   context_window.used_percentage      pre-computed, null before first response
#   rate_limits.five_hour.used_percentage
#   rate_limits.five_hour.resets_at     epoch SECONDS (number)
# rate_limits appears only for Claude.ai subscribers, and only once a window
# has been reported by the API; each segment is omitted when its data is absent.

input=$(cat)

# Tokyo Night (Storm) palette, matching ~/.config/alacritty/alacritty.toml.
# To retheme, change only these seven values -- nothing below references a
# colour directly.
C_DIM=$'\033[38;2;68;75;106m'      # #444b6a  chrome, separators, empty bar
C_FG=$'\033[38;2;169;177;214m'     # #a9b1d6  numbers
C_ACCENT=$'\033[38;2;122;162;247m' # #7aa2f7  folder
C_LABEL=$'\033[38;2;187;154;247m'  # #bb9af7  labels
C_OK=$'\033[38;2;158;206;106m'     # #9ece6a  under 50%
C_WARN=$'\033[38;2;224;175;104m'   # #e0af68  50-79%
C_BAD=$'\033[38;2;247;118;142m'    # #f7768e  80%+
BOLD=$'\033[1m'
RESET=$'\033[0m'

# Joined on "|" rather than @tsv: tab is IFS whitespace, so bash collapses
# runs of tabs and drops empty fields, shifting present values into absent
# fields' slots.
IFS='|' read -r model cwd ctx_in ctx_out ctx_size ctx_pct five_pct five_reset <<< "$(
  printf '%s' "$input" | jq -r '[
    (.model.display_name // .model.id // ""),
    (.workspace.current_dir // .cwd // ""),
    (.context_window.total_input_tokens // ""),
    (.context_window.total_output_tokens // ""),
    (.context_window.context_window_size // ""),
    (.context_window.used_percentage // ""),
    (.rate_limits.five_hour.used_percentage // ""),
    (.rate_limits.five_hour.resets_at // "")
  ] | map(tostring) | join("|")')"

folder="${cwd##*/}"
[ -z "$folder" ] && folder="/"

# Green under 50%, amber 50-79%, red at 80%+.
pct_color() {
  if   [ "$1" -ge 80 ]; then printf '%s' "$C_BAD"
  elif [ "$1" -ge 50 ]; then printf '%s' "$C_WARN"
  else printf '%s' "$C_OK"
  fi
}

# Model first, in the same dim tone as the reset timer, then the folder.
# Drop any parenthetical suffix so "Opus 5 (1M context)" renders as "Opus 5".
model="${model%% (*}"
line=""
[ -n "$model" ] && line="${C_DIM}${model}${RESET} "
line="${line}${C_ACCENT}${BOLD}${folder}${RESET}"

# --- context: progress bar + absolute token counts ---
if [ -n "$ctx_pct" ]; then
  pct=$(printf '%.0f' "$ctx_pct")
  [ "$pct" -lt 0 ] && pct=0
  [ "$pct" -gt 100 ] && pct=100
  used_tok=""
  if [ -n "$ctx_in" ] && [ -n "$ctx_size" ]; then
    # Documented "used" figure is input + output tokens.
    used_tok=$(( $(printf '%.0f' "$ctx_in") + $(printf '%.0f' "${ctx_out:-0}") ))
  fi

  # The window is 1M, so a percentage threshold would warn far too late.
  # Warn from 200k tokens on; red stays at 80% of the window.
  if   [ "$pct" -ge 80 ]; then color="$C_BAD"
  elif [ -n "$used_tok" ] && [ "$used_tok" -ge 200000 ]; then color="$C_WARN"
  elif [ -z "$used_tok" ]; then color=$(pct_color "$pct")
  else color="$C_OK"
  fi

  width=10
  filled=$(( (pct * width + 50) / 100 ))
  bar=""
  for ((i = 0; i < width; i++)); do
    if [ "$i" -lt "$filled" ]; then bar="${bar}█"; else bar="${bar}░"; fi
  done
  # Colour the filled run and the empty run separately.
  line="${line} ${C_DIM}[${RESET}${color}${bar:0:filled}${C_DIM}${bar:filled}${C_DIM}]${RESET}"

  if [ -n "$used_tok" ]; then
    used_k=$(( ( used_tok + 500 ) / 1000 ))
    size_k=$(( ( $(printf '%.0f' "$ctx_size") + 500 ) / 1000 ))
    line="${line} ${C_FG}${used_k}k${C_DIM}/${C_FG}${size_k}k${RESET}"
  fi
fi

# --- 5-hour rate limit window: percentage + time until reset ---
if [ -n "$five_pct" ]; then
  lpct=$(printf '%.0f' "$five_pct")
  lcolor=$(pct_color "$lpct")
  seg="${C_LABEL}5h limit:${RESET} ${lcolor}${lpct}%${RESET}"

  if [ -n "$five_reset" ]; then
    now=${EPOCHSECONDS:-$(date +%s)}
    # resets_at is epoch seconds; tolerate an ISO string just in case.
    case $five_reset in
      *[!0-9.]*) reset=$(date -d "$five_reset" +%s 2>/dev/null) ;;
      *)         reset=$(printf '%.0f' "$five_reset") ;;
    esac
    if [ -n "$reset" ]; then
      left=$(( reset - now ))
      [ "$left" -lt 0 ] && left=0
      seg="${seg} ${C_DIM}($(printf '%dh:%02dm' $(( left / 3600 )) $(( (left % 3600) / 60 )))"$'\033[0m'"${C_DIM})${RESET}"
    fi
  fi
  line="${line} ${C_DIM}|${RESET} ${seg}"
fi

printf '%s' "$line"
