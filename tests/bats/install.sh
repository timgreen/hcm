#!/bin/bash

cd "$(dirname "$(readlink -f "$0")")"

BATS_VERSION=0.4.0

BATS_PATH=bats-$BATS_VERSION
[ -d "$BATS_PATH" ] || {
  wget https://github.com/sstephenson/bats/archive/v${BATS_VERSION}.zip
  unzip v${BATS_VERSION}.zip -d .
  rm -f v${BATS_VERSION}.zip
}
ln -sf "$BATS_PATH/bin/bats" bats
