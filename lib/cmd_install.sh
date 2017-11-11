#!/bin/bash

BASE=$(dirname $(readlink -f "$0"))
source "$BASE/lib_msg.sh"
source "$BASE/lib_config.sh"

main() {
  [ -r "$MAIN_CONFIG" ] || {
    cat << EOF
Cannot read main config "\$HOME/.hcm/config.yml".
EOF
    exit 1
  }
  echo "Install"
  echo -n "Default script shell: "
  get_shell
  echo -n "Modules: "
  get_modules
}

[[ "$DEBUG" != "" ]] && set -x
main "$@"
