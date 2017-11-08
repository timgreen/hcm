
hcm() {
  docker-compose -f docker/docker-compose.yml run --user="$UID:$GID" hcm "$@"
}

assert_starts_with() {
  [ "${1:0:${#2}}" == "$2" ]
}
