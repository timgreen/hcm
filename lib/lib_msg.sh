
color() {
  if $USE_COLORS; then
    echo -n "$(tput setaf $1)$2$(tput op)"
  else
    echo -n "$2"
  fi
}

highlight() {
  color 13 "$1" # Purple
}
