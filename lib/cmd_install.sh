#!/bin/bash

BASE=$(dirname $(readlink -f "$0"))
source "$BASE/lib_msg.sh"
source "$BASE/lib_config.sh"
source "$BASE/hook_helper.sh"
source "$BASE/lib_hook.sh"

DRY_RUN=true

install::install_module() {
  modulePath="$1"
  absModulePath="$(config::get_module_path "$modulePath")"
  hook::install "$absModulePath"
}

install::install_modules() {
  config::get_modules | while read modulePath; do
    install::install_module "$modulePath"
  done
}

main() {
  POSITIONAL=()
  while (( $# > 0 )); do
    case "$1" in
      -n|--dry-run)
        shift
        DRY_RUN=true
        ;;
      -f|--no-dry-run)
        shift
        DRY_RUN=false
        ;;
      *)
        POSITIONAL+=("$1") # save it in an array for later
        shift
        ;;
    esac
  done
  set -- "${POSITIONAL[@]}" # restore positional parameters

  config::verify
  install::install_modules
}

[[ "$DEBUG" != "" ]] && set -x
set -e
main "$@"
