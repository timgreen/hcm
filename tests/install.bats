#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "target"
  mkdir -p "expected_target"
  mkdir -p "source"
}

teardown() {
  rm -fr "target"
  rm -fr "expected_target"
  rm -fr "source"
}

@test "install: fail when <dir> not exist" {
  run hcm install nonexistent_dir
  [ "$status" -eq 1 ]
}

@test "install: fail when <dir> doesn't contains HCM_MODULE or HCM_MCD_ROOT" {
  unzip fixtures/invalid_dir.zip -d source

  run hcm install source/invalid_dir

  [ "$status" -eq 1 ]
}

@test "install: empty config module (CM)" {
  unzip fixtures/empty_cm.zip -d source
  hcm install source/empty_cm

  mkdir -p expected_target/.hcm/modules/empty_cm/config
  ln -s $(readlink -f source/empty_cm) expected_target/.hcm/modules/empty_cm/source

  diff -rq --no-dereference expected_target target
}

@test "install: empty managed config directory (MCD)" {
  unzip fixtures/empty_mcd.zip -d source

  hcm install source/empty_mcd

  diff -rq --no-dereference expected_target target
}
