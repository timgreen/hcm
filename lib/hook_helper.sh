HOOK_HELPER=true

[ -z "$INIT_PATH" ]  && source "$(dirname "${BASH_SOURCE[0]}")"/lib_path.sh
[ -z "$INIT_TOOLS" ] && source "$(dirname "${BASH_SOURCE[0]}")"/lib_tools.sh

# http://stackoverflow.com/questions/16989598/bash-comparing-version-numbers#answer-24067243
version_gt() {
  test "$(printf '%s\n' "$@" | tools::sort -V | head -n 1)" != "$1";
}

version_gte() {
  [[ "$1" == "$2" ]] || version_gt "$1" "$2"
}

# Link $from to $to, assuming both are abs path and $to is under $HOME.
#
# Also log linked target in $HCM_MODULE_LINK_LOG.
link() {
  [ -z "$HCM_MODULE_LINK_LOG" ] && exit 2

  local from="$1"
  local to="$2"

  mkdir -p "$(dirname "$to")"
  ln -s "$(path::relative_to "$(dirname "$to")/" "$from")" "$to"

  mkdir -p "$(dirname "$HCM_MODULE_LINK_LOG")"
  path::relative_to "$HOME/" "$to" >> "$HCM_MODULE_LINK_LOG"
}
