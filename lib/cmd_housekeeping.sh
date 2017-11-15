#!/bin/bash

BASE="$(dirname "$(readlink -f "$0")")"

# Options
MAX_LEVEL=5
DRY_RUN=true
source "$BASE/lib_dry_run.sh"

# Only take the action iff this is not dry_run
action() {
  if [ $DRY_RUN == true ]; then
    echo "$@"
    return
  fi
  "$@"
}

check_file() {
  local file="$1"

  if ! readlink -e "$file" > /dev/null; then
    action unlink "$file"
  fi
}

check_dir() {
  local target_dir="$1"
  local level="$2"
  local removed_something=false
  local keeped_something=false

  # Reached max level
  (( $level >= $MAX_LEVEL )) && return
  # Skip for git repo
  [ -d "$target_dir/.git" ] && return

  IFS=$'\n'
  for file in $(find -P "$target_dir" -maxdepth 1 -mindepth 1 -type l); do
    check_file "$file"
    [ -r "$file" ] && keeped_something=true || removed_something=true
  done

  for dir in $(find -P "$target_dir" -maxdepth 1 -mindepth 1 -type d); do
    check_dir "$dir" $((level + 1))
    [ -d "$dir" ] && keeped_something=true || removed_something=true
  done

  if $removed_something && ! $keeped_something; then
    action rmdir --ignore-fail-on-non-empty "$target_dir"
  fi
}

main() {
  # TODO: support flags
  #       - max_level
  local POSITIONAL=()
  while (( $# > 0 )); do
    case "$1" in
      *)
        POSITIONAL+=("$1") # save it in an array for later
        shift
        ;;
    esac
  done
  set -- "${POSITIONAL[@]}" # restore positional parameters

  check_dir "$HOME" 0
}

[[ "$DEBUG" != "" ]] && set -x
main "$@"
