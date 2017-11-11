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
