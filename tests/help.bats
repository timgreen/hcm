#!/usr/bin/env bats

load test_helper

@test "Show usage without arguments" {
  run hcm
  [ "$status" -eq 0 ]
  [ "${lines[0]}" == "usage: hcm <command> [<args>]" ]
}

@test "No error for help" {
  run hcm help
  [ "$status" -eq 0 ]
}

@test "No error for help help" {
  run hcm help help
  [ "$status" -eq 0 ]
}

@test "Show usage for install" {
  run hcm help install
  [ "$status" -eq 0 ]
  assert_starts_with "${lines[0]}" 'usage: hcm install '
}

@test "Show usage for remove-legacy" {
  run hcm help remove-legacy
  [ "$status" -eq 0 ]
  assert_starts_with "${lines[0]}" 'usage: hcm remove-legacy '
}

@test "Return error and show usage for unknown cmd" {
  run hcm help unknown
  [ "$status" -eq 1 ]
  assert_starts_with "${lines[0]}" 'Unknown command '
  assert_starts_with "${lines[1]}" 'usage: hcm '
}

