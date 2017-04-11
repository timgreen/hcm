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
  mkdir target/b
  echo b > target/b/b1
  mkdir target/c
  touch target/c/c1
  cp -r target/* expected_target/

  hcm remove-legacy

  diff -rq --no-dereference expected_target target
}
