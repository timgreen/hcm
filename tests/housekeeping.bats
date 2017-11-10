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

  hcm housekeeping -f

  diff_home_status "$fixture"
}

@test "housekeep: only remove dead links" {
  fixture="./fixtures/housekeeping/only_remove_dead_links"
  use_fixture "$fixture"

  hcm housekeeping -f

  diff_home_status "$fixture"
}

@test "housekeep: removes dead links in dirs" {
  fixture="./fixtures/housekeeping/removes_dead_links_in_dirs"
  use_fixture "$fixture"

  hcm housekeeping -f

  diff_home_status "$fixture"
}

@test "housekeep: removes links to dead links" {
  fixture="./fixtures/housekeeping/removes_links_to_dead_link"
  use_fixture "$fixture"

  hcm housekeeping -f

  diff_home_status "$fixture"
}

@test "housekeep: dry-run -n" {
  fixture="./fixtures/housekeeping/removes_links_to_dead_link"
  use_fixture "$fixture"

  hcm housekeeping -n

  diff -rq --no-dereference "$fixture/before" test_home
}

@test "housekeep: dry-run --dry-run" {
  fixture="./fixtures/housekeeping/removes_links_to_dead_link"
  use_fixture "$fixture"

  hcm housekeeping --dry-run

  diff -rq --no-dereference "$fixture/before" test_home
}

@test "housekeep: cleanup empty dir" {
  fixture="./fixtures/housekeeping/cleanup_empty_dir/"
  use_fixture "$fixture"

  hcm housekeeping -f

  diff_home_status "$fixture"
}
