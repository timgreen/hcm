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

@test "sync: partial install, stop on error" {
  fixture="./fixtures/sync/partial_install"
  use_fixture "$fixture"

  run hcm sync -f
  [ "$status" -eq 1 ]

  diff_home_status "$fixture"
}

@test "sync: provide & require bash" {
  fixture="./fixtures/sync/provide_require_bash"
  use_fixture "$fixture"

  hcm sync -f

  diff_home_status "$fixture"
}

@test "sync: provide & require zsh" {
  fixture="./fixtures/sync/provide_require_zsh"
  use_fixture "$fixture"

  hcm sync -f

  diff_home_status "$fixture"
}

@test "sync: run install hook in bash" {
  fixture="./fixtures/sync/hook_install_bash"
  use_fixture "$fixture"

  hcm sync -f

  diff_home_status "$fixture"
}

@test "sync: run uninstall hook in bash" {
  diff_dir \
      "./fixtures/sync/hook_uninstall_bash/before" \
      "./fixtures/sync/hook_install_bash/after"
  fixture="./fixtures/sync/hook_uninstall_bash"
  use_fixture "$fixture"

  sed -i '/- b$/d' "test_home/repo/hcm.yml"
  hcm sync -f

  diff_home_status "$fixture"
}

@test "sync: run install hook in zsh" {
  fixture="./fixtures/sync/hook_install_zsh"
  use_fixture "$fixture"

  hcm sync -f

  diff_home_status "$fixture"
}

@test "sync: run uninstall hook in zsh" {
  diff_dir \
      "./fixtures/sync/hook_uninstall_zsh/before" \
      "./fixtures/sync/hook_install_zsh/after"
  fixture="./fixtures/sync/hook_uninstall_zsh"
  use_fixture "$fixture"

  sed -i '/- b$/d' "test_home/repo/hcm.yml"
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

  # step 3
  diff_dir \
      "./fixtures/sync/step_3_update_one_module/before" \
      "./fixtures/sync/step_2_remove_one_module/after"
  fixture="./fixtures/sync/step_3_update_one_module"
  use_fixture "$fixture"
  echo "updated file in a" > "test_home/repo/module_a/a"
  echo "new file in a" > "test_home/repo/module_a/new"
  hcm sync -f
  diff_home_status "$fixture"
}

@test "sync: use helper in hook - zsh" {
  fixture="./fixtures/sync/use_helpers_in_hook_zsh"
  use_fixture "$fixture"

  hcm sync -f

  diff_home_status "$fixture"
}

@test "sync: use helper in hook - bash" {
  fixture="./fixtures/sync/use_helpers_in_hook_bash"
  use_fixture "$fixture"

  hcm sync -f

  diff_home_status "$fixture"
}

@test "sync: use exported env in hook - zsh" {
  fixture="./fixtures/sync/env_export_zsh"
  use_fixture "$fixture"

  hcm sync -f

  diff_home_status "$fixture"
}

@test "sync: use exported env in hook - bash" {
  fixture="./fixtures/sync/env_export_bash"
  use_fixture "$fixture"

  hcm sync -f

  diff_home_status "$fixture"
}

@test "sync: use if in hook - zsh" {
  fixture="./fixtures/sync/use_if_hook_zsh"
  use_fixture "$fixture"

  hcm sync -f

  diff_home_status "$fixture"
}

@test "sync: use if in hook - bash" {
  fixture="./fixtures/sync/use_if_hook_bash"
  use_fixture "$fixture"

  hcm sync -f

  diff_home_status "$fixture"
}

@test "sync: repects .after list" {
  fixture="./fixtures/sync/repect_after_list"
  use_fixture "$fixture"

  hcm sync -f

  diff_home_status "$fixture"
}

@test "sync: repects .hcmignore" {
  fixture="./fixtures/sync/hcmignore"
  use_fixture "$fixture"

  hcm sync -f

  diff_home_status "$fixture"
}

