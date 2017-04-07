#!/bin/bash

BASE=$(dirname $(readlink -f "$0"))

MODULE_FILE="HCM_MODULE"
ROOT_FILE="HCM_MCD_ROOT"

is_cm() {
  dir="$1"
  # cm dir should contains a regular file: $MODULE_FILE
  [ -f "$dir/$MODULE_FILE" ] && [ ! -L "$dir/$MODULE_FILE" ]
}

is_root() {
  dir="$1"
  # root dir should contains a regular file: $ROOT_FILE
  [ -f "$dir/$ROOT_FILE" ] && [ ! -L "$dir/$ROOT_FILE" ]
}

process_root() {
  echo "root: $1"
}

process_cm() {
  echo "cm: $1"
}

process_root_or_cm() {
  dir="$1"
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
      dir="$1"
      shift
      process_root_or_cm "$dir"
    done
  fi
}

main "$@"
