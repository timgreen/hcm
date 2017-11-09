#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p test_home
}

teardown() {
  rm -fr test_home
}

@test "help: show usage without arguments" {
  run hcm
  [ "$status" -eq 0 ]
  skip
  [ "${lines[0]}" == "usage: hcm <command> [<args>]" ]
}

@test "help: no error for help" {
  run hcm help
  [ "$status" -eq 0 ]
}

@test "help: no error for help help" {
  run hcm help help
  [ "$status" -eq 0 ]
}

@test "help: show usage for install" {
  run hcm help install
  [ "$status" -eq 0 ]
  assert_starts_with "${lines[0]}" 'usage: hcm install '
}

@test "help: show usage for housekeeping" {
  run hcm help housekeeping
  [ "$status" -eq 0 ]
  assert_starts_with "${lines[0]}" 'usage: hcm housekeeping'
}

@test "help: return error and show usage when help a unknown cmd" {
  run hcm help unknown
  [ "$status" -eq 1 ]
  skip
  assert_starts_with "${lines[0]}" 'Unknown command '
  assert_starts_with "${lines[1]}" 'usage: hcm '
}

@test "help: return error and show usage for unknown cmd" {
  run hcm unknown
  [ "$status" -eq 1 ]
  skip
  assert_starts_with "${lines[0]}" 'Unknown command '
  assert_starts_with "${lines[1]}" 'usage: hcm '
}

