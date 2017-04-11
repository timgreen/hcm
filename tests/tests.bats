#!/usr/bin/env bats

setup() {
  mkdir -p "$BATS_TEST_DIRNAME/target"
}

teardown() {
  rm -fr "$BATS_TEST_DIRNAME/target"
}

hcm() {
  HCM_TARGET_DIR="$BATS_TEST_DIRNAME/target" ../hcm "$@"
}

@test "Fail when install non exist <dir>" {
  run hcm install nonexistent_dir
  [ "$status" -eq 1 ]
}
