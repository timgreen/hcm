#!/bin/bash

BASE=$(dirname $(readlink -f "$0"))

MODULE_FILE="HCM_MODULE"
ROOT_FILE="HCM_MCD_ROOT"

is_cm() {
  local dir="$1"
  # cm dir should contains a regular file: $MODULE_FILE
  [ -f "$dir/$MODULE_FILE" ] && [ ! -L "$dir/$MODULE_FILE" ]
}

is_root() {
  local dir="$1"
  # root dir should contains a regular file: $ROOT_FILE
  [ -f "$dir/$ROOT_FILE" ] && [ ! -L "$dir/$ROOT_FILE" ]
}

is_same_file() {
  [[ "$(readlink -f "$1")" == "$(readlink -f "$2")" ]]
}

process_sub_dir() {
  local dir="$1"
  echo "sub_dir: $1"

  if is_cm "$dir"; then
    process_cm "$dir"
  else
    local empty_dir=true
    for sub_dir in $(find -H "$dir" -maxdepth 1 -mindepth 1 -xtype d); do
      process_sub_dir "$sub_dir"
      empty_dir=false
    done

    for file in $(find -H "$dir" -maxdepth 1 -mindepth 1 -xtype f); do
      echo "Unmanaged file: $file"
      empty_dir=false
    done

    echo "Empty dir: $dir"
  fi
}

process_root() {
  local dir="$1"

  echo "root: $dir"

  for sub_dir in $(find -H "$dir" -maxdepth 1 -mindepth 1 -xtype d); do
    process_sub_dir "$sub_dir"
  done

  for file in $(find -H "$dir" -maxdepth 1 -mindepth 1 -xtype f); do
    is_same_file "$dir/$ROOT_FILE" "$file" && continue

    echo "Unmanaged file: $file"
  done
}

process_cm() {
  echo "cm: $1"
}

process_root_or_cm() {
  local dir="$1"
  if is_root "$dir"; then
    process_root "$dir"
  elif is_cm "$dir"; then
    process_cm "$dir"
  else
    echo "Invalid dir: $dir"
    exit 1
  fi
}

main() {
  if (( $# == 0 )); then
    # use CWD if <dir>
    main "$PWD"
  else
    while (( $# > 0 )); do
      local dir="$1"
      shift
      process_root_or_cm "$(readlink -f $dir)"
    done
  fi
}

main "$@"
