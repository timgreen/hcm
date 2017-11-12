#!/bin/bash

BASE=$(dirname $(readlink -f "$0"))
source "$BASE/lib_msg.sh"
source "$BASE/lib_config.sh"

DRY_RUN=true

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
    cat << EOF
Cannot read main config "\$HOME/.hcm/config.yml".
EOF
    exit 1
  }
  echo "Install"
  echo -n "Default script shell: "
  config::get_shell
  echo -n "Modules: "
  config::get_modules
}

[[ "$DEBUG" != "" ]] && set -x
main "$@"
