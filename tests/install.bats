#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "target"
  mkdir -p "expected_target"
  mkdir -p "source"
}

teardown() {
  (( $DEBUG_TEST )) && {
    rm -fr "/dev/shm/bats_debug/$BATS_TEST_NAME"
    mkdir -p "/dev/shm/bats_debug/$BATS_TEST_NAME"
    cp -r "target" "expected_target" "source" "/dev/shm/bats_debug/$BATS_TEST_NAME"
  }

  rm -fr "target"
  rm -fr "expected_target"
  rm -fr "source"
}

@test "install: fail when <dir> not exist" {
  run hcm install nonexistent_dir
  [ "$status" -eq 1 ]
}

@test "install: fail when <dir> doesn't contains HCM_MODULE or HCM_MCD_ROOT" {
  unzip fixtures/invalid_dir.zip -d source
  run hcm install source/invalid_dir

  [ "$status" -eq 1 ]
}

@test "install: empty config module (CM)" {
  unzip fixtures/empty_cm.zip -d source
  hcm install source/empty_cm

  mkdir -p expected_target/.hcm/modules/empty_cm/config
  ln -s $(readlink -f source)/empty_cm expected_target/.hcm/modules/empty_cm/source

  diff -rq --no-dereference expected_target target
}

@test "install: empty managed config directory (MCD)" {
  unzip fixtures/empty_mcd.zip -d source
  hcm install source/empty_mcd

  diff -rq --no-dereference expected_target target
}

@test "install: single CM" {
  unzip fixtures/single_cm.zip -d source

  mkdir -p expected_target/.hcm/modules/single_cm/config
  ln -s $(readlink -f source)/single_cm expected_target/.hcm/modules/single_cm/source

  ln -s $(readlink -f source)/single_cm/x expected_target/.hcm/modules/single_cm/config/x
  mkdir -p expected_target/.hcm/modules/single_cm/config/a
  ln -s $(readlink -f source)/single_cm/a/y expected_target/.hcm/modules/single_cm/config/a/y
  mkdir -p expected_target/.hcm/modules/single_cm/config/.c
  ln -s $(readlink -f source)/single_cm/.c/z expected_target/.hcm/modules/single_cm/config/.c/z

  ln -s $(readlink -f target)/.hcm/modules/single_cm/config/x expected_target/x
  mkdir -p expected_target/a
  ln -s $(readlink -f target)/.hcm/modules/single_cm/config/a/y expected_target/a/y
  mkdir -p expected_target/.c
  ln -s $(readlink -f target)/.hcm/modules/single_cm/config/.c/z expected_target/.c/z

  hcm install source/single_cm

  diff -rq --no-dereference expected_target target
}

@test "install: multiple CMs" {
  unzip fixtures/multiple_cms.zip -d source

  mkdir -p expected_target/.hcm/modules/cm1/config
  ln -s $(readlink -f source)/cm1 expected_target/.hcm/modules/cm1/source
  ln -s $(readlink -f source)/cm1/a expected_target/.hcm/modules/cm1/config/a
  mkdir -p expected_target/.hcm/modules/cm2/config
  ln -s $(readlink -f source)/cm2 expected_target/.hcm/modules/cm2/source
  ln -s $(readlink -f source)/cm2/b expected_target/.hcm/modules/cm2/config/b

  ln -s $(readlink -f target)/.hcm/modules/cm1/config/a expected_target/a
  ln -s $(readlink -f target)/.hcm/modules/cm2/config/b expected_target/b

  hcm install source/cm1 source/cm2

  diff -rq --no-dereference expected_target target
}

@test "install: error on CM name crash" {
  unzip fixtures/cm_names_crash.zip -d source

  run hcm install source/a/cm_name source/b/cm_name

  [ "$status" -eq 1 ]
}

@test "install: simple MCD" {
  unzip fixtures/simple_mcd.zip -d source

  mkdir -p expected_target/.hcm/modules/cm1/config
  ln -s $(readlink -f source)/simple_mcd/cm1 expected_target/.hcm/modules/cm1/source
  ln -s $(readlink -f source)/simple_mcd/cm1/a expected_target/.hcm/modules/cm1/config/a
  mkdir -p expected_target/.hcm/modules/cm1/config/common_dir
  ln -s $(readlink -f source)/simple_mcd/cm1/common_dir/common_file_1 expected_target/.hcm/modules/cm1/config/common_dir/common_file_1
  mkdir -p expected_target/.hcm/modules/cm2/config
  ln -s $(readlink -f source)/simple_mcd/group1/cm2 expected_target/.hcm/modules/cm2/source
  mkdir -p expected_target/.hcm/modules/cm2/config/common_dir
  ln -s $(readlink -f source)/simple_mcd/group1/cm2/common_dir/common_file_2 expected_target/.hcm/modules/cm2/config/common_dir/common_file_2
  mkdir -p expected_target/.hcm/modules/cm3/config
  ln -s $(readlink -f source)/simple_mcd/group1/cm3 expected_target/.hcm/modules/cm3/source
  ln -s $(readlink -f source)/simple_mcd/group1/cm3/b expected_target/.hcm/modules/cm3/config/b

  ln -s $(readlink -f target)/.hcm/modules/cm1/config/a expected_target/a
  mkdir -p expected_target/common_dir
  ln -s $(readlink -f target)/.hcm/modules/cm1/config/common_dir/common_file_1 expected_target/common_dir/common_file_1
  ln -s $(readlink -f target)/.hcm/modules/cm2/config/common_dir/common_file_2 expected_target/common_dir/common_file_2
  ln -s $(readlink -f target)/.hcm/modules/cm3/config/b expected_target/b

  hcm install source/simple_mcd

  diff -rq --no-dereference expected_target target
}

@test "install: error on config crash" {
  unzip fixtures/config_crash.zip -d source

  run hcm install source/config_crash

  [ "$status" -eq 1 ]
}

@test "install: MCD and CM" {
  unzip fixtures/simple_mcd.zip -d source
  unzip fixtures/empty_cm.zip -d source

  mkdir -p expected_target/.hcm/modules/cm1/config
  ln -s $(readlink -f source)/simple_mcd/cm1 expected_target/.hcm/modules/cm1/source
  ln -s $(readlink -f source)/simple_mcd/cm1/a expected_target/.hcm/modules/cm1/config/a
  mkdir -p expected_target/.hcm/modules/cm1/config/common_dir
  ln -s $(readlink -f source)/simple_mcd/cm1/common_dir/common_file_1 expected_target/.hcm/modules/cm1/config/common_dir/common_file_1
  mkdir -p expected_target/.hcm/modules/cm2/config
  ln -s $(readlink -f source)/simple_mcd/group1/cm2 expected_target/.hcm/modules/cm2/source
  mkdir -p expected_target/.hcm/modules/cm2/config/common_dir
  ln -s $(readlink -f source)/simple_mcd/group1/cm2/common_dir/common_file_2 expected_target/.hcm/modules/cm2/config/common_dir/common_file_2
  mkdir -p expected_target/.hcm/modules/cm3/config
  ln -s $(readlink -f source)/simple_mcd/group1/cm3 expected_target/.hcm/modules/cm3/source
  ln -s $(readlink -f source)/simple_mcd/group1/cm3/b expected_target/.hcm/modules/cm3/config/b
  mkdir -p expected_target/.hcm/modules/empty_cm/config
  ln -s $(readlink -f source)/empty_cm expected_target/.hcm/modules/empty_cm/source

  ln -s $(readlink -f target)/.hcm/modules/cm1/config/a expected_target/a
  mkdir -p expected_target/common_dir
  ln -s $(readlink -f target)/.hcm/modules/cm1/config/common_dir/common_file_1 expected_target/common_dir/common_file_1
  ln -s $(readlink -f target)/.hcm/modules/cm2/config/common_dir/common_file_2 expected_target/common_dir/common_file_2
  ln -s $(readlink -f target)/.hcm/modules/cm3/config/b expected_target/b

  hcm install source/simple_mcd source/empty_cm

  diff -rq --no-dereference expected_target target
}

@test "install: ignore README and README.*" {
  unzip fixtures/ignore_readme.zip -d source

  mkdir -p expected_target/.hcm/modules/ignore_readme/config
  ln -s $(readlink -f source)/ignore_readme expected_target/.hcm/modules/ignore_readme/source
  ln -s $(readlink -f source)/ignore_readme/a expected_target/.hcm/modules/ignore_readme/config/a

  ln -s $(readlink -f target)/.hcm/modules/ignore_readme/config/a expected_target/a

  hcm install source/ignore_readme

  diff -rq --no-dereference expected_target target
}

@test "install: post_link hook" {
  unzip fixtures/simple_hook_function.zip -d source

  mkdir -p expected_target/.hcm/modules/simple_hook_function/config
  mkdir -p expected_target/.hcm/modules/simple_hook_function/hook
  ln -s $(readlink -f source)/simple_hook_function expected_target/.hcm/modules/simple_hook_function/source
  echo "created by hook function" > expected_target/a

  hcm install source/simple_hook_function

  diff -rq --no-dereference expected_target target
}

@test "install: use variables in hook" {
  unzip fixtures/use_variable_in_hook.zip -d source

  mkdir -p expected_target/.hcm/modules/use_variable_in_hook/config
  mkdir -p expected_target/.hcm/modules/use_variable_in_hook/hook
  ln -s $(readlink -f source)/use_variable_in_hook expected_target/.hcm/modules/use_variable_in_hook/source
  cat << EOF > expected_target/variables
PWD: $(readlink -f target)/.hcm/modules/use_variable_in_hook/hook
HOOK_CWD: $(readlink -f target)/.hcm/modules/use_variable_in_hook/hook
CM_DIR: $(readlink -f source)/use_variable_in_hook
HCM_TARGET_DIR: $(readlink -f target)
EOF

  hcm install source/use_variable_in_hook

  diff -rq --no-dereference expected_target target
}

@test "install: skip CM if pre_link hook exit 3" {
  unzip fixtures/skip_cm_if_pre_link_hook_exit_3.zip -d source

  mkdir -p expected_target/.hcm/modules/skip_cm_if_pre_link_hook_exit_3/config
  mkdir -p expected_target/.hcm/modules/skip_cm_if_pre_link_hook_exit_3/hook
  ln -s $(readlink -f source)/skip_cm_if_pre_link_hook_exit_3 expected_target/.hcm/modules/skip_cm_if_pre_link_hook_exit_3/source

  hcm install source/skip_cm_if_pre_link_hook_exit_3

  diff -rq --no-dereference expected_target target
}

@test "install: softlinked CM" {
  unzip fixtures/softlinked_cm.zip -d source

  mkdir -p expected_target/.hcm/modules/cm/config
  ln -s $(readlink -f source)/softlinked_cm/mcd/cm expected_target/.hcm/modules/cm/source
  ln -s $(readlink -f source)/softlinked_cm/mcd/cm/file expected_target/.hcm/modules/cm/config/file

  ln -s $(readlink -f target)/.hcm/modules/cm/config/file expected_target/file

  hcm install source/softlinked_cm/mcd

  diff -rq --no-dereference expected_target target
}

@test "install: softlinked group" {
  unzip fixtures/softlinked_group.zip -d source

  mkdir -p expected_target/.hcm/modules/cm/config
  ln -s $(readlink -f source)/softlinked_group/mcd/group/cm expected_target/.hcm/modules/cm/source
  ln -s $(readlink -f source)/softlinked_group/mcd/group/cm/file expected_target/.hcm/modules/cm/config/file

  ln -s $(readlink -f target)/.hcm/modules/cm/config/file expected_target/file

  hcm install source/softlinked_group/mcd

  diff -rq --no-dereference expected_target target
}

@test "install: treat softlink as regular file" {
  unzip fixtures/softlinks.zip -d source

  mkdir -p expected_target/.hcm/modules/cm/config
  ln -s $(readlink -f source)/softlinks/cm expected_target/.hcm/modules/cm/source
  ln -s $(readlink -f source)/softlinks/cm/file_outside_cm expected_target/.hcm/modules/cm/config/file_outside_cm
  ln -s $(readlink -f source)/softlinks/cm/dir_outside_cm expected_target/.hcm/modules/cm/config/dir_outside_cm

  ln -s $(readlink -f target)/.hcm/modules/cm/config/file_outside_cm expected_target/file_outside_cm
  ln -s $(readlink -f target)/.hcm/modules/cm/config/dir_outside_cm expected_target/dir_outside_cm

  hcm install source/softlinks/cm

  diff -rq --no-dereference expected_target target
}

@test "install: raise the hook error (pre_link exit 1)" {
  unzip fixtures/hook_error.zip -d source

  run hcm install source/hook_error/pre_link_exit_1

  [ "$status" -eq 1 ]
}

@test "install: raise the hook error (pre_link exit 4)" {
  unzip fixtures/hook_error.zip -d source

  run hcm install source/hook_error/pre_link_exit_4

  [ "$status" -eq 1 ]
}
