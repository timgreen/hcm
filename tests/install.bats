#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p test_home
}

teardown() {
  rm -fr test_home
}

@test "install: a simple empty module" {
  fixture="./fixtures/install/simple_empty_module"
  use_fixture "$fixture"

  hcm install

  diff_home_status "$fixture"
}

@test "uninstall: a simple empty module" {
  diff -r --no-dereference \
      "./fixtures/install/simple_empty_module_uninstall/before" \
      "./fixtures/install/simple_empty_module/after"

  fixture="./fixtures/install/simple_empty_module_uninstall"
  use_fixture "$fixture"

  sed -i '/- empty$/d' "test_home/repo/config.yml"
  hcm install

  diff_home_status "$fixture"
}

@test "install: a simple module with empty config" {
  fixture="./fixtures/install/only_link_files"
  use_fixture "$fixture"

  hcm install

  diff_home_status "$fixture"
}

@test "uninstall: a simple module with empty config" {
  diff -r --no-dereference \
      "./fixtures/install/only_link_files_uninstall/before" \
      "./fixtures/install/only_link_files/after"

  fixture="./fixtures/install/only_link_files_uninstall"
  use_fixture "$fixture"

  sed -i '/- files_to_link$/d' "test_home/repo/config.yml"
  hcm install

  diff_home_status "$fixture"
}

@test "install: complex step by step test" {
  # step 1
  fixture="./fixtures/install/step_1_install_two_modules"
  use_fixture "$fixture"
  hcm install
  diff_home_status "$fixture"
}
