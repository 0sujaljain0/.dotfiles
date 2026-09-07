#!/bin/sh
# ~/.config/tmux/git-segment.sh
# usage: git-segment.sh <path> <client_width> [gold] [accent] [muted] [border] [green] [red]
#
# Prints a styled git segment for tmux's status line, sized to the client width:
#   < 70 cols  : nothing
#   < 110 cols :  branch ●                (dot = anything dirty)
#   < 140 cols :  branch ↑1 ↓2 +3 !2 ?1 ⚑1
#   otherwise  : ...plus (owner/repo)

path=$1
width=${2:-200}
gold=${3:-yellow}   accent=${4:-magenta} muted=${5:-brightblack}
border=${6:-brightblack} green=${7:-green} red=${8:-red}

[ "$width" -lt 70 ] 2>/dev/null && exit 0
cd "$path" 2>/dev/null || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

# One call gives branch, ahead/behind and every changed file.
# --no-optional-locks: never fight your editor for index.lock.
status=$(git --no-optional-locks status --porcelain=v2 --branch 2>/dev/null) || exit 0

eval "$(printf '%s\n' "$status" | awk '
  $1=="#" && $2=="branch.head" { print "head=\"" $3 "\"" }
  $1=="#" && $2=="branch.ab"   { print "ahead=" substr($3,2) " behind=" substr($4,2) }
  $1=="1" || $1=="2"           { if (substr($2,1,1)!=".") s++; if (substr($2,2,1)!=".") u++ }
  $1=="?"                      { n++ }
  $1=="u"                      { c++ }
  END { printf "staged=%d unstaged=%d untracked=%d conflicts=%d\n", s, u, n, c }
')"
ahead=${ahead:-0} behind=${behind:-0}

[ "$head" = "(detached)" ] && head="@$(git rev-parse --short HEAD 2>/dev/null)"
stashes=$(git rev-list --walk-reflogs --count refs/stash 2>/dev/null || echo 0)

trunc() { # trunc <string> <max>
  if [ ${#1} -gt "$2" ]; then printf '%s…' "$(printf '%s' "$1" | cut -c1-$(($2 - 1)))"; else printf '%s' "$1"; fi
}

dirty=""
[ "$conflicts" -gt 0 ] && dirty="$dirty #[fg=$red]✗$conflicts"
[ "$staged"    -gt 0 ] && dirty="$dirty #[fg=$green]+$staged"
[ "$unstaged"  -gt 0 ] && dirty="$dirty #[fg=$accent]!$unstaged"
[ "$untracked" -gt 0 ] && dirty="$dirty #[fg=$muted]?$untracked"
[ "$stashes"   -gt 0 ] && dirty="$dirty #[fg=$muted]⚑$stashes"

sync=""
[ "$ahead"  -gt 0 ] && sync="$sync #[fg=$gold]↑$ahead"
[ "$behind" -gt 0 ] && sync="$sync #[fg=$gold]↓$behind"

branch_color=$gold
[ "$conflicts" -gt 0 ] && branch_color=$red

if [ "$width" -lt 110 ]; then
  mark=""; [ -n "$dirty" ] && mark=" #[fg=$accent]●"
  printf '#[fg=%s,bold] %s%s #[fg=%s,nobold]│' "$branch_color" "$(trunc "$head" 18)" "$mark" "$border"
  exit 0
fi

remote=""
if [ "$width" -ge 140 ]; then
  r=$(git remote get-url origin 2>/dev/null | sed -E 's#/*$##; s#\.git$##; s#^.*[:/]([^/]+/[^/]+)$#\1#')
  [ -n "$r" ] && remote=" #[fg=$muted]($(trunc "$r" 32))"
fi

printf '#[fg=%s,bold] %s#[nobold]%s%s%s #[fg=%s,nobold]│' \
  "$branch_color" "$(trunc "$head" 28)" "$sync" "$dirty" "$remote" "$border"
