HOOK_HELPER=true

# http://stackoverflow.com/questions/16989598/bash-comparing-version-numbers#answer-24067243
version_gt() {
  test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1";
}

version_gte() {
  [[ "$1" == "$2" ]] || version_gt "$1" "$2"
}

# Why not just `realpath --relative-to=A B`?
#
# 1. realpath will resolve B if it is a softlink, but I prefer not.
# 2. in some old system, realpath dont have --relative-to option
#
# Returns the relative path to $a for $b.
#
# NOTE, this function assume $a ends with '/'.
relative_to() {
  local a="$1"
  local b="$2"
  local prefix="$3"

  if [[ "$b" = "$a"* ]]; then
    echo "$prefix${b#$a}"
  else
    relative_to "$(dirname "$a")/" "$b" "../$prefix"
  fi
}

# Link $from to $to, assuming both are abs path and $to is under $HOME.
#
# Also log linked target in $HCM_MODULE_LINK_LOG.
link() {
  [ -z "$HCM_MODULE_LINK_LOG" ] && exit 2

  local from="$1"
  local to="$2"

  mkdir -p "$(dirname "$to")"
  ln -s "$(relative_to "$(dirname "$to")/" "$from")" "$to"

  mkdir -p "$(dirname "$HCM_MODULE_LINK_LOG")"
  relative_to "$HOME/" "$to" >> "$HCM_MODULE_LINK_LOG"
}
