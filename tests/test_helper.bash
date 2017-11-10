
hcm() {
  docker-compose -f docker/docker-compose.yml run --user="$UID:$GID" hcm "$@"
}

assert_starts_with() {
  [ "${1:0:${#2}}" == "$2" ]
}

use_fixture() {
  fixture_dir="$1"
  rm -fr test_home
  cp -r "$fixture_dir/before" test_home
}

diff_home_status() {
  fixture_dir="$1"
  diff -r --no-dereference "$fixture_dir/after" test_home
}
