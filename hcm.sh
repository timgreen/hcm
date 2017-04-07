#!/bin/bash

BASE=$(dirname $(readlink -f "$0"))

cmd="$1"
shift

set -e
case "$cmd" in
  install)
    sh $BASE/lib/cmd_install.sh "$@"
  ;;
  help)
    sh $BASE/lib/cmd_help.sh "$@"
  ;;
  "")
    sh $BASE/lib/cmd_help.sh
  ;;
  *)
    echo "Unknown command $(tput setaf 13)$cmd$(tput op)"
    echo
    sh $BASE/lib/cmd_help.sh
    exit 1
esac
