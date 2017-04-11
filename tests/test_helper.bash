
hcm() {
  HCM_TARGET_DIR="$BATS_TEST_DIRNAME/target" ../hcm "$@"
}

assert_starts_with() {
  [ "${1:0:${#2}}" == "$2" ]
}
