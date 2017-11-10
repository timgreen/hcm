#!/bin/bash

# Options
MAX_LEVEL=5
DRY_RUN=false

# Only take the action iff this is not dry_run
action() {
  if [ $DRY_RUN == true ]; then
    return
  fi
  "$@"
}

# returns true if dead softlink has been removed
check_file() {
  local file="$1"

  if ! readlink -e "$file" > /dev/null; then
    action unlink "$file"
    return 0
  fi

  return 1
}

# returns true if removed any dead softlink(s)
check_dir() {
  local target_dir="$1"
  local level="$2"
  local removed_something=false

  # Reached max level
  (( $level >= $MAX_LEVEL )) && return 0
  # Skip for git repo
  [ -d "$target_dir/.git" ] && return 0

  IFS=$'\n'
  for file in $(find -P "$target_dir" -maxdepth 1 -mindepth 1 -type l); do
    check_file "$file" && removed_something=true || IGNORE_ERROR=x
  done

  for dir in $(find -P "$target_dir" -maxdepth 1 -mindepth 1 -type d); do
    check_dir "$dir" $((level + 1)) && removed_something=true || IGNORE_ERROR=x
  done

  $removed_something || return 1
  action rmdir --ignore-fail-on-non-empty "$target_dir"
  return 0
}

main() {
  # TODO: support flags
  #       - max_level
  POSITIONAL=()
  while (( $# > 0 )); do
    case "$1" in
      -n|--dry-run)
        shift
        DRY_RUN=true
        ;;
      *)
        POSITIONAL+=("$1") # save it in an array for later
        shift
        ;;
    esac
  done
  set -- "${POSITIONAL[@]}" # restore positional parameters

  check_dir "$HOME" 0 || IGNORE_ERROR=x
}

[[ "$DEBUG" != "" ]] && set -x
main "$@"
