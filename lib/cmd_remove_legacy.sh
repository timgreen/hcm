#!/bin/bash

BASE=$(dirname $(readlink -f "$0"))
source "$BASE/lib_path.sh"

# returns true if legacy file removed
maybe_remove_legacy_file() {
  local file="$1"
  local linked_path="$(readlink "$file")"

  # only care about the link from tracking dir
  is_in_hcm_root "$linked_path" || return 1

  # unlink if tracking file is not a softlink
  if [ ! -L "$linked_path" ]; then
    unlink "$file"
    return 0
  fi

  # unlink if relative path not match
  if [[ "$(relative_path_for_tracking_file "$linked_path")" != "$(relative_path_for_target_file "$file")" ]]; then
    unlink "$file"
    return 0
  fi

  return 1
}

# returns true if any legacy file(s) removed
scan_and_remove_legacy_dir() {
  local target_dir="$1"
  local level="$2"
  local removed_something=false

  (( $level >= 5 )) && return 0

  IFS=$'\n'
  for file in $(find -P "$target_dir" -maxdepth 1 -mindepth 1 -type l); do
    maybe_remove_legacy_file "$file" && removed_something=true || IGNORE_ERROR=x
  done

  for dir in $(find -P "$target_dir" -maxdepth 1 -mindepth 1 -type d); do
    scan_and_remove_legacy_dir "$dir" $((level + 1)) && removed_something=true || IGNORE_ERROR=x
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
    maybe_remove_legacy_file "$file" || IGNORE_ERROR=x
  done

  for dir in $(find -P "$HCM_TARGET_DIR" -maxdepth 1 -mindepth 1 -type d); do
    is_same_path "$dir" "$HCM_ROOT" && continue
    scan_and_remove_legacy_dir "$dir" 1 || IGNORE_ERROR=x
  done
}

main() {
  # TODO: support flags
  do_full_scan
}

[[ "$DEBUG" != "" ]] && set -x
main "$@"
