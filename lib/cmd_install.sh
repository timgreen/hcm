#!/bin/bash

BASE=$(dirname $(readlink -f "$0"))

main() {
  [ -r "$MAIN_CONFIG" ] || {
    cat << EOF
Cannot read main config "\$HOME/.hcm/config.yml".
EOF
    exit 1
  }
  echo "Install"
}

[[ "$DEBUG" != "" ]] && set -x
main "$@"
