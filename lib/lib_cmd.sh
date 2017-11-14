INIT_CMD=true

is_valid_cmd_name() {
  echo "$1" | grep -qs "^[a-z][a-z-]*[a-z]$"
}

cmd_to_filename() {
  echo "$1" | tr - _
}
