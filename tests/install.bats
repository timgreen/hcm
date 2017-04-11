#!/usr/bin/env bats

setup() {
  mkdir -p "$BATS_TEST_DIRNAME/target"
  mkdir -p "$BATS_TEST_DIRNAME/expected_target"
}

teardown() {
  rm -fr "$BATS_TEST_DIRNAME/target"
  rm -fr "$BATS_TEST_DIRNAME/expected_target"
}

hcm() {
  HCM_TARGET_DIR="$BATS_TEST_DIRNAME/target" ../hcm "$@"
}

@test "Fail when install non exist <dir>" {
  run hcm install nonexistent_dir
  [ "$status" -eq 1 ]
}

@test "Fail when install <dir> without HCM_MODULE or HCM_MCD_ROOT" {
  run hcm install sources/invalid_dir
  [ "$status" -eq 1 ]
}

@test "Install empty config module (CM)" {
  hcm install sources/empty_cm

  mkdir -p expected_target/.hcm/modules/empty_cm/config
  ln -s $(readlink -f sources/empty_cm) expected_target/.hcm/modules/empty_cm/source

  diff -rq --no-dereference expected_target target
}

@test "Install empty managed config directory (MCD)" {
  hcm install sources/empty_mcd

  diff -rq --no-dereference expected_target target
}
