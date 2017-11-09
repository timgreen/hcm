#!/bin/bash

MAX_LEVEL=5

# returns true if dead softlink has been removed
check_file() {
  local file="$1"

  if ! readlink -e "$file" > /dev/null; then
    unlink "$file"
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
  rmdir --ignore-fail-on-non-empty "$target_dir"
  return 0
}

do_housekeeping() {
  IFS=$'\n'
  for file in $(find -P "$HOME" -maxdepth 1 -mindepth 1 -type l); do
    check_file "$file" || IGNORE_ERROR=x
  done

  for dir in $(find -P "$HOME" -maxdepth 1 -mindepth 1 -type d); do
    check_dir "$dir" 1 || IGNORE_ERROR=x
  done
}

main() {
  # TODO: support flags
  #       - max_level
  #       - n, dry_run
  do_housekeeping
}

[[ "$DEBUG" != "" ]] && set -x
main "$@"
