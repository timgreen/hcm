#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "target"
  mkdir -p "expected_target"
  mkdir -p "source"
}

teardown() {
  (( $DEBUG_TEST )) && {
    rm -fr "/dev/shm/bats_debug/$BATS_TEST_NAME"
    mkdir -p "/dev/shm/bats_debug/$BATS_TEST_NAME"
    cp -r "target" "expected_target" "source" "/dev/shm/bats_debug/$BATS_TEST_NAME"
  }

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

@test "install: single CM" {
  unzip fixtures/single_cm.zip -d source

  mkdir -p expected_target/.hcm/modules/single_cm/config
  ln -s $(readlink -f source/single_cm) expected_target/.hcm/modules/single_cm/source

  ln -s $(readlink -f source/single_cm/x) expected_target/.hcm/modules/single_cm/config/x
  mkdir -p expected_target/.hcm/modules/single_cm/config/a
  ln -s $(readlink -f source/single_cm/a/y) expected_target/.hcm/modules/single_cm/config/a/y
  mkdir -p expected_target/.hcm/modules/single_cm/config/.c
  ln -s $(readlink -f source/single_cm/.c/z) expected_target/.hcm/modules/single_cm/config/.c/z

  ln -s $(readlink -m target/.hcm/modules/single_cm/config/x) expected_target/x
  mkdir -p expected_target/a
  ln -s $(readlink -m target/.hcm/modules/single_cm/config/a/y) expected_target/a/y
  mkdir -p expected_target/.c
  ln -s $(readlink -m target/.hcm/modules/single_cm/config/.c/z) expected_target/.c/z

  hcm install source/single_cm

  diff -rq --no-dereference expected_target target
}

@test "install: multiple CMs" {
  unzip fixtures/multiple_cms.zip -d source

  mkdir -p expected_target/.hcm/modules/cm1/config
  ln -s $(readlink -f source/cm1) expected_target/.hcm/modules/cm1/source
  ln -s $(readlink -f source/cm1/a) expected_target/.hcm/modules/cm1/config/a
  mkdir -p expected_target/.hcm/modules/cm2/config
  ln -s $(readlink -f source/cm2) expected_target/.hcm/modules/cm2/source
  ln -s $(readlink -f source/cm2/b) expected_target/.hcm/modules/cm2/config/b

  ln -s $(readlink -m target/.hcm/modules/cm1/config/a) expected_target/a
  ln -s $(readlink -m target/.hcm/modules/cm2/config/b) expected_target/b

  hcm install source/cm1 source/cm2

  diff -rq --no-dereference expected_target target
}
