#!/bin/bash

BASE=$(dirname $(readlink -f "$0"))
source "$BASE/lib_path.sh"

run_hook() {
  action="$2"

  set -a
  CM_DIR="$1"
  set +a

  (
    source "$(module_file_for "$CM_DIR")"

    if [[ "$(type -t "$action")" == "function" ]]; then
      $action
    fi
  )
}

run_hook "$@"
