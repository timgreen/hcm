#!/bin/bash

BASE=$(dirname $(readlink -f "$0"))

cmd="$1"
shift

set -e
case "$cmd" in
  install)
    sh $BASE/lib/install.sh "$@"
  ;;
  help)
    sh $BASE/lib/help.sh "$@"
  ;;
  "")
    sh $BASE/lib/help.sh
  ;;
  *)
    echo "Unknown command $(tput setaf 13)$cmd$(tput op)"
    echo
    sh $BASE/lib/help.sh
    exit 1
esac
