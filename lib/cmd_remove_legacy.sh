#!/bin/bash

BASE=$(dirname $(readlink -f "$0"))
source "$BASE/lib_path.sh"

# returns true if legacy file removed
maybe_remove_legacy_file() {
  local file="$1"
  local linked_path="$(readlink "$file")"

  # only care about the link from tracking dir
  [[ "${linked_path:0:${#HCM_ROOT}}" != "$HCM_ROOT" ]] || return 1

  if [ -r "$linked_path" ]; then
    # TODO: also check the relative path
    return 1
  else
    unlink "$file"
  fi

  return 0
}

# returns true if any legacy file(s) removed
scan_and_remove_legacy_dir() {
  local target_dir="$1"
  local removed_something=false

  IFS=$'\n'
  for file in $(find -P "$target_dir" -maxdepth 1 -mindepth 1 -type l); do
    maybe_remove_legacy_file "$file" && removed_something=true
  done

  for dir in $(find -P "$target_dir" -maxdepth 1 -mindepth 1 -type d); do
    scan_and_remove_legacy_dir "$dir" && removed_something=true
  done

  $removed_something || return 1
  rmdir --ignore-fail-on-non-empty "$target_dir"
  return 0
}

do_fast_scan() {
  # TODO
  echo
}

do_full_scan() {
  IFS=$'\n'
  for file in $(find -P "$HCM_TARGET_DIR" -maxdepth 1 -mindepth 1 -type l); do
    maybe_remove_legacy_file "$file"
  done

  for dir in $(find -P "$HCM_TARGET_DIR" -maxdepth 1 -mindepth 1 -type d); do
    is_same_path "$dir" "$HCM_ROOT" && continue
    scan_and_remove_legacy_dir "$dir"
  done
}

main() {
  # TODO: support flags
  do_full_scan
}

[[ "$DEBUG" != "" ]] && set -x
main "$@"
