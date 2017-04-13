
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

error() {
  color 1 "Error: $1" >&2
  exit 1
}

info() {
  echo "$1"
}
