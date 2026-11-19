#!/usr/bin/env bash
# Status line, left to right: what is running (model, effort), where (git branch),
# this session's state (context, prompt cache), then the account's limits and identity.
input=$(cat)
# Fields are split on \x1f, not tabs: read merges adjacent whitespace separators,
# which would shift the fields after an empty one.
now=$(date +%s)

# Gruvbox light foreground colors, as 24-bit ANSI escapes.
rgb() { printf '\033[38;2;%d;%d;%dm' "0x${1:0:2}" "0x${1:2:2}" "0x${1:4:2}"; }
red=$(rgb 9d0006) green=$(rgb 79740e) yellow=$(rgb b57614) blue=$(rgb 076678)
purple=$(rgb 8f3f71) aqua=$(rgb 427b58) gray=$(rgb 928374) bold=$'\033[1m' reset=$'\033[0m'
sep=" ${gray}|${reset} "

# level <percent left> -> green when plenty is left, yellow when low, red when nearly out.
level() {
  if [ "$1" -gt 50 ]; then printf '%s' "$green"
  elif [ "$1" -gt 20 ]; then printf '%s' "$yellow"
  else printf '%s' "$red"; fi
}

# dur <seconds> -> a short duration such as 45s, 12m, 2h10m or 3d4h.
dur() {
  local s=$(( $1 < 0 ? 0 : $1 ))
  if [ "$s" -lt 60 ]; then printf '%ds' "$s"
  elif [ "$s" -lt 3600 ]; then printf '%dm' $((s / 60))
  elif [ "$s" -lt 86400 ]; then printf '%dh%dm' $((s / 3600)) $((s % 3600 / 60))
  else printf '%dd%dh' $((s / 86400)) $((s % 86400 / 3600)); fi
}

IFS=$'\x1f' read -r model effort dir used tokens cache_warm cache_expires < <(echo "$input" | jq -r '
  def k: if . >= 1000000 then "\(. / 100000 | round / 10)M" elif . >= 1000 then "\(. / 1000 | round)k" else "\(.)" end;
  [ .model.display_name // "?",
    .effort.level // "-",
    .workspace.current_dir // .cwd // "-",
    (.context_window.used_percentage // 0 | round),
    (.context_window | if .context_window_size then "\(.total_input_tokens // 0 | k)/\(.context_window_size | k)" else "-" end),
    (.prompt_cache | if . and .caching_observed then (.warm | tostring) else "-" end),
    .prompt_cache.expires_at // "-"
  ] | map(tostring) | join("\u001f")')

out="${bold}${blue}${model}${reset}"
[ -n "$effort" ] && [ "$effort" != - ] && out="$out ${gray}${effort}${reset}"

branch=$(git -C "$dir" branch --show-current 2>/dev/null)
[ -z "$branch" ] && branch=$(git -C "$dir" rev-parse --short HEAD 2>/dev/null)
[ -n "$branch" ] && out="$out${sep}${aqua}${branch}${reset}"

out="$out${sep}context $(level $((100 - used)))${used}%${reset}"
[ "$tokens" != - ] && out="$out ${gray}(${tokens})${reset}"

if [ "$cache_warm" = true ] && [ "$cache_expires" != - ] && [ "${cache_expires%.*}" -gt "$now" ]; then
  out="$out${sep}cache ${aqua}$(dur $(( ${cache_expires%.*} - now )))${reset}"
elif [ "$cache_warm" != - ]; then
  out="$out${sep}cache ${gray}cold${reset}"
fi

# Every window under .rate_limits that reports used_percentage, in input order.
while IFS=$'\x1f' read -r name pct resets; do
  [ -n "$pct" ] || continue
  case "$name" in
    five_hour) label="5h" ;;
    seven_day) label="7d" ;;
    spend_limit) label="spend" ;;
    *) label=${name//_/ } ;;
  esac
  left=$(printf '%.0f' "$(echo "100 - $pct" | bc -l)")
  [ "$left" -lt 0 ] && left=0
  out="$out${sep}$label left $(level "$left")${left}%${reset}"
  [ -n "$resets" ] && out="$out ${gray}($(dur $(( ${resets%.*} - now ))))${reset}"
done < <(echo "$input" | jq -r '(.rate_limits // {}) | to_entries[] | select(.value | type == "object") | [.key, (.value.used_percentage // ""), (.value.resets_at // "") | tostring] | join("\u001f")')

# Logged-in account: not in the statusLine input, so read two keys from .claude.json
# in the active config dir, which CLAUDE_CONFIG_DIR moves away from $HOME.
# A personal account's organization is named after its email, so it adds nothing.
acct=$(jq -r '.oauthAccount | if . then .emailAddress as $e
  | [$e, (.organizationName | select(. and ($e == null or (contains($e) | not))))]
  | map(select(. != null and . != "")) | join(" / ") else empty end' "${CLAUDE_CONFIG_DIR:-$HOME}/.claude.json" 2>/dev/null)
[ -n "$acct" ] && out="$out${sep}${purple}${acct}${reset}"
printf '%s\n' "$out"
