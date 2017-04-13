
color() {
  if $USE_COLORS; then
    echo -e "$(tput setaf $1)$2$(tput op)"
  else
    echo -e "$2"
  fi
}

highlight() {
  color 13 "$1" # Purple
}

error_msg() {
  color 1 "Error: $1" >&2
}

internal_error_msg() {
  color 1 "Internal error: $1" >&2
}

info() {
  echo "$1"
}
