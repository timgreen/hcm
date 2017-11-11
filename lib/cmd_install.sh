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
  echo "Default script shell: $(get_shell)"
}

[[ "$DEBUG" != "" ]] && set -x
main "$@"
