#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p test_home
}

teardown() {
  rm -fr test_home
}

@test "sync: install a simple empty module" {
  fixture="./fixtures/sync/install_simple_empty_module"
  use_fixture "$fixture"

  hcm sync -f

  diff_home_status "$fixture"
}

@test "sync: uninstall a simple empty module" {
  diff_dir \
      "./fixtures/sync/uninstall_simple_empty_module/before" \
      "./fixtures/sync/install_simple_empty_module/after"

  fixture="./fixtures/sync/uninstall_simple_empty_module"
  use_fixture "$fixture"

  sed -i '/- empty$/d' "test_home/repo/hcm.yml"
  hcm sync -f

  diff_home_status "$fixture"
}

@test "sync: install a simple module with empty config" {
  fixture="./fixtures/sync/install_only_link_files"
  use_fixture "$fixture"

  hcm sync -f

  diff_home_status "$fixture"
}

@test "sync: uninstall a simple module with empty config" {
  diff_dir \
      "./fixtures/sync/uninstall_only_link_files/before" \
      "./fixtures/sync/install_only_link_files/after"

  fixture="./fixtures/sync/uninstall_only_link_files"
  use_fixture "$fixture"

  sed -i '/- files_to_link$/d' "test_home/repo/hcm.yml"
  hcm sync -f

  diff_home_status "$fixture"
}

@test "sync: complex step by step test" {
  # step 1
  fixture="./fixtures/sync/step_1_install_two_modules"
  use_fixture "$fixture"
  hcm sync -f
  diff_home_status "$fixture"

  # step 2
  diff_dir \
      "./fixtures/sync/step_2_remove_one_module/before" \
      "./fixtures/sync/step_1_install_two_modules/after"
  fixture="./fixtures/sync/step_2_remove_one_module"
  use_fixture "$fixture"
  sed -i '/- module_b$/d' "test_home/repo/hcm.yml"
  hcm sync -f
  diff_home_status "$fixture"
}
