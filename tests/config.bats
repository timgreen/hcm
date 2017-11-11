#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p test_home
}

teardown() {
  rm -fr test_home
}

@test "config: error when home config not found" {
  run hcm install
  [ "$status" -eq 1 ]
}

@test "config: error when home config not readable" {
  mkdir test_home/.hcm
  touch test_home/.hcm/config.yml
  chmod a-r test_home/.hcm/config.yml

  run hcm install
  [ "$status" -eq 1 ]
}

@test "config: empty home config is OK" {
  mkdir test_home/.hcm
  touch test_home/.hcm/config.yml

  run hcm install
  [ "$status" -eq 0 ]
}

@test "config: modules field is optional" {
  mkdir test_home/.hcm
  echo 'shell: zsh' > test_home/.hcm/config.yml

  run hcm install
  [ "$status" -eq 0 ]
}

@test "config: modules field can be empty" {
  mkdir test_home/.hcm
  echo 'shell: zsh' > test_home/.hcm/config.yml
  echo 'module:' > test_home/.hcm/config.yml

  run hcm install
  [ "$status" -eq 0 ]
}

@test "config: modules field can be empty (2)" {
  mkdir test_home/.hcm
  echo 'module:' > test_home/.hcm/config.yml

  run hcm install
  [ "$status" -eq 0 ]
}
