#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p test_home
}

teardown() {
  rm -fr test_home
}

@test "install: error when home config not found" {
  run hcm install
  [ "$status" -eq 1 ]
}

@test "install: error when home config not readable" {
  mkdir test_home/.hcm
  touch test_home/.hcm/config.yml
  chmod a-r test_home/.hcm/config.yml

  run hcm install
  [ "$status" -eq 1 ]
}

@test "install: empty home config is OK" {
  mkdir test_home/.hcm
  touch test_home/.hcm/config.yml

  run hcm install
  [ "$status" -eq 0 ]
}
