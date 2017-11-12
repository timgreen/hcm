#!/bin/bash

BASE=$(dirname $(readlink -f "$0"))
source "$BASE/lib_msg.sh"
source "$BASE/lib_config.sh"

DRY_RUN=true

verify_configs() {
  mainConfigPath="$(readlink -f $MAIN_CONFIG)"
  echo "Main config realpath: $mainConfigPath"
  config::verify_main
  echo -n "Default script shell: "
  config::get_shell
  echo "Modules: "
  config::get_modules | sed 's/^/  - /'

  config::get_modules | while read modulePath; do
    config::verify_module "$mainConfigPath" "$modulePath"
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

  [ -r "$MAIN_CONFIG" ] || {
    msg::error 'Cannot read main config "\$HOME/.hcm/config.yml".'
    exit 1
  }

  verify_configs
}

[[ "$DEBUG" != "" ]] && set -x
set -e
main "$@"
