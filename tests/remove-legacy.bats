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

@test "remove-legacy: ignore regular files" {
  echo a > target/a
  echo a > expected_target/a
  mkdir target/b expected_target/b
  echo b > target/b/b1
  echo b > expected_target/b/b1
  mkdir target/c expected_target/c
  touch target/c/c1
  touch expected_target/c/c1

  hcm remove-legacy

  diff -rq --no-dereference expected_target target
}

