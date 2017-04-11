#!/bin/bash

BASE=$(dirname $(readlink -f "$0"))
source "$BASE/lib_path.sh"

main() {
  rm -fr "$HCM_ROOT"
  bash "$BASE/cmd_remove_legacy.sh" --no-fast-scan
}

[[ "$DEBUG" != "" ]] && set -x
main
