#!/bin/bash

cd "$(dirname "$(readlink -f "$0")")"

./bats/install.sh

if (( $# == 0 )); then
  ./bats/bats *.bats
else
  ./bats/bats "$@"
fi
