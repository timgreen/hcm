
skip_this_cm() {
  exit $HOOK_EXIT_SKIP
}

# http://stackoverflow.com/questions/16989598/bash-comparing-version-numbers#answer-24067243
version_gt() {
  test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1";
}
