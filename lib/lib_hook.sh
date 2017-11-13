
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

  if [[ "$MODULE_CONFIG" == "$relativeFilePath" ]]; then
    # ignore module config
    return
  fi

  mkdir -p "$(dirname "$HOME/$relativeFilePath")"
  ln -s "$(relative_to "$(dirname "$HOME/$relativeFilePath")/" "$file")" "$HOME/$relativeFilePath"
}

# Why not just `realpath --relative-to=A B`?
#
# 1. realpath will resolve B if it is a softlink, but I prefer not.
# 2. in some old system, realpath dont have --relative-to option
#
# Returns the relative path to $a for $b.
#
# NOTE, this function assume $a ends with '/'.
relative_to() {
  a="$1"
  b="$2"
  prefix="$3"

  if [[ "$b" = "$a"* ]]; then
    echo "$prefix${b#$a}"
  else
    relative_to "$(dirname "$a")/" "$b" "../$prefix"
  fi
}
