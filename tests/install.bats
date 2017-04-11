#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "target"
  mkdir -p "expected_target"
}

teardown() {
  rm -fr "target"
  rm -fr "expected_target"
}

@test "install: fail when <dir> not exist" {
  run hcm install nonexistent_dir
  [ "$status" -eq 1 ]
}

@test "install: fail when <dir> doesn't contains HCM_MODULE or HCM_MCD_ROOT" {
  run hcm install sources/invalid_dir
  [ "$status" -eq 1 ]
}

@test "install: empty config module (CM)" {
  hcm install sources/empty_cm

  mkdir -p expected_target/.hcm/modules/empty_cm/config
  ln -s $(readlink -f sources/empty_cm) expected_target/.hcm/modules/empty_cm/source

  diff -rq --no-dereference expected_target target
}

@test "install: empty managed config directory (MCD)" {
  hcm install sources/empty_mcd

  diff -rq --no-dereference expected_target target
}
