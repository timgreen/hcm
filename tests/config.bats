#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p test_home
}

teardown() {
  rm -fr test_home
}

@test "config: error when home config not found" {
  run hcm sync
  [ "$status" -eq 1 ]
}

@test "config: error when home config not readable" {
  mkdir test_home/.hcm
  touch test_home/.hcm/hcm.yml
  chmod a-r test_home/.hcm/hcm.yml

  run hcm sync
  [ "$status" -eq 1 ]
}

@test "config: empty home config is OK" {
  mkdir test_home/.hcm
  touch test_home/.hcm/hcm.yml

  run hcm sync
  [ "$status" -eq 0 ]
}

@test "config: modules field is optional" {
  mkdir test_home/.hcm
  echo 'shell: zsh' > test_home/.hcm/hcm.yml

  run hcm sync
  [ "$status" -eq 0 ]
}

@test "config: modules field can be empty" {
  mkdir test_home/.hcm
  echo 'shell: zsh' > test_home/.hcm/hcm.yml
  echo 'module:' > test_home/.hcm/hcm.yml

  run hcm sync
  [ "$status" -eq 0 ]
}

@test "config: modules field can be empty (2)" {
  mkdir test_home/.hcm
  echo 'module:' > test_home/.hcm/hcm.yml

  run hcm sync
  [ "$status" -eq 0 ]
}

@test "config: error when modules type is not array" {
  mkdir test_home/.hcm

  echo 'modules: a' > test_home/.hcm/hcm.yml
  run hcm sync
  [ "$status" -eq 1 ]

  echo 'modules: 1' > test_home/.hcm/hcm.yml
  run hcm sync
  [ "$status" -eq 1 ]

  echo 'modules: ' > test_home/.hcm/hcm.yml
  echo '  a: b'  >> test_home/.hcm/hcm.yml
  run hcm sync
  [ "$status" -eq 1 ]
}

@test "config: error when modules item type is not path" {
  mkdir test_home/.hcm

  cat > test_home/.hcm/hcm.yml << EOF
modules:
  - a: b
EOF
  run hcm sync
  [ "$status" -eq 1 ]
}

@test "config: error when module not exists" {
  mkdir test_home/.hcm

  cat > test_home/.hcm/hcm.yml << EOF
modules:
  - a
EOF
  run hcm sync
  [ "$status" -eq 1 ]
}

@test "config: error when '.after' listed invalid module" {
  fixture="./fixtures/sync/step_1_install_two_modules"
  use_fixture "$fixture"

  sed -i '/- module_b/d' test_home/repo/hcm.yml
  echo "after:" >> test_home/repo/module_a/module.yml
  echo "  - ../module_b" >> test_home/repo/module_a/module.yml

  run hcm sync
  [ "$status" -eq 1 ]
}

@test "config: error when '.after' listed non-exists module" {
  fixture="./fixtures/sync/step_1_install_two_modules"
  use_fixture "$fixture"

  echo "after:" >> test_home/repo/module_a/module.yml
  echo "  - ../module_c" >> test_home/repo/module_a/module.yml

  run hcm sync
  [ "$status" -eq 1 ]
}

@test "config: error with circular dependency in '.after'" {
  fixture="./fixtures/config/circular_dependency"
  use_fixture "$fixture"

  run hcm sync
  [ "$status" -eq 1 ]
}

@test "config: error with invalid value in '.requires'" {
  fixture="./fixtures/config/invalid_requires"
  use_fixture "$fixture"

  run hcm sync
  [ "$status" -eq 1 ]
}
