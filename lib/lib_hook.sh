
hook::install() {
  modulePath="$1"
  hook::_do_link_all "$modulePath" "$modulePath"
}

hook::_do_link_all() {
  modulePath="$1"
  dir="$2"

  IFS=$'\n'
  for file in $(find -P "$dir" \( -type l -o -type f \)); do
    hook::_do_link "$modulePath" "$file"
  done
}

hook::_do_link() {
  modulePath="$1"
  file="$2"
  relativeFilePath="${file#$modulePath/}"

  # ignore module config
  if [[ "$MODULE_CONFIG" == "$relativeFilePath" ]]; then
    return
  fi

  link "$file" "$HOME/$relativeFilePath"
}

