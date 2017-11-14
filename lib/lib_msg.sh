INIT_MSG=true

[ -t 1 ] && USE_COLORS=true || USE_COLORS=false

msg::color() {
  if $USE_COLORS; then
    echo -e "$(tput setaf $1)$2$(tput op)"
  else
    echo -e "$2"
  fi
}

msg::highlight() {
  msg::color 13 "$1" # Purple
}

msg::error() {
  msg::color 1 "Error: $1" >&2
}

msg::internal_error() {
  msg::color 1 "Internal error: $1" >&2
}

msg::hook_error_msg() {
  local action="$1"
  local dir="$2"
  local result="$3"
  local status="$4"

  msg::color 1 "Hook error: $action $dir"
  echo $result
}

msg::info() {
  echo "$1"
}
