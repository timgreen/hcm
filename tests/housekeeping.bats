#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p test_home
}

teardown() {
  rm -fr test_home
}

@test "housekeep: ignore regular files" {
  fixture="./fixtures/housekeeping/keep_regular_files"
  use_fixture "$fixture"

  hcm housekeeping

  diff_home_status "$fixture"
}

@test "housekeep: only remove dead links" {
  fixture="./fixtures/housekeeping/only_remove_dead_links"
  use_fixture "$fixture"

  hcm housekeeping

  diff_home_status "$fixture"
}

@test "housekeep: removes dead links in dirs" {
  fixture="./fixtures/housekeeping/removes_dead_links_in_dirs"
  use_fixture "$fixture"

  hcm housekeeping

  diff_home_status "$fixture"
}
