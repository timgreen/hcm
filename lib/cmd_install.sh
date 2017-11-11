#!/bin/bash

BASE=$(dirname $(readlink -f "$0"))

main() {
  echo "Install"
}

[[ "$DEBUG" != "" ]] && set -x
main "$@"
