#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p test_home
}

teardown() {
# rm -fr test_home
echo
}

@test "housekeep: ignore regular files" {
  fixture="./fixtures/housekeeping/keep_regular_files/"
  use_fixture "$fixture"

  hcm housekeeping

  diff_home_status "$fixture"
}
