#!/bin/bash

BASE=$(dirname $(readlink -f "$0"))
source "$BASE/lib_msg.sh"
source "$BASE/lib_config.sh"

DRY_RUN=true

verify_configs() {
  echo "Main config realpath: $(readlink -f $MAIN_CONFIG)"
  echo -n "Default script shell: "
  config::get_shell
  modules="$(config::get_modules)"
  echo "Modules: "
  echo "$modules" | sed 's/^/  - /'


  while read modulePath; do
    echo $modulePath
  done <<< "$modules"
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

  [ -r "$MAIN_CONFIG" ] || {
    msg::error 'Cannot read main config "\$HOME/.hcm/config.yml".'
    exit 1
  }

  verify_configs
}

[[ "$DEBUG" != "" ]] && set -x
set -e
main "$@"
